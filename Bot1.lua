redis = (loadfile "redis.lua")()
redis = redis.connect('127.0.0.1', 6379)

function dl_cb(arg, data)
end

local clock = os.clock
function sleep(s)
  local delay = redis:get("bot2delay") or 5
  local randomdelay = math.random (tonumber(delay)- (tonumber(delay)/2), tonumber(delay)+ (tonumber(delay)/2))
  local t0 = clock()
  while clock() - t0 <= tonumber(randomdelay) do end
end

function get_admin ()
  if redis:get('bot2adminset') then
    return true
  else
    print("sudo id :")
    admin=io.read()
    redis:del("bot2admin")
    redis:sadd("bot2admin", admin)
    redis:set('bot2adminset',true)
  end
  return print("Owner: ".. admin)
end
function get_bot (i, adigram)
  function bot_info (i, adigram)
    redis:set("bot2id",adigram.id_)
    if adigram.first_name_ then
      redis:set("bot2fname",adigram.first_name_)
    end
    if adigram.last_name_ then
      redis:set("bot2lanme",adigram.last_name_)
    end
    redis:set("bot2num",adigram.phone_number_)
    return adigram.id_
  end
  tdcli_function ({ID = "GetMe",}, bot_info, nil)
  end
  function reload(chat_id,msg_id)
    loadfile("./bot-2.lua")()
    send(chat_id, msg_id, "<code>ربات با موفقیت ریست شد و اماده به کار است✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
  end
  function is_adigram(msg)
    local var = false
    local hash = 'bot2admin'
    local user = msg.sender_user_id_
    local Adigram = redis:sismember(hash, user)
    if Adigram then
      var = true
    end
    return var
  end
  function writefile(filename, input)
    local file = io.open(filename, "w")
    file:write(input)
    file:flush()
    file:close()
    return true
  end
  function process_join(i, adigram)
    if adigram.code_ == 429 then
      local message = tostring(adigram.message_)
      local Time = message:match('%d+')
      redis:setex("bot2maxjoin", tonumber(Time), true)
    else
      redis:srem("bot2goodlinks", i.link)
      redis:sadd("bot2savedlinks", i.link)
    end
  end
  function process_link(i, adigram)
    if (adigram.is_group_ or adigram.is_supergroup_channel_) then
      redis:srem("bot2waitelinks", i.link)
      redis:sadd("bot2goodlinks", i.link)
    elseif adigram.code_ == 429 then
      local message = tostring(adigram.message_)
      local Time = message:match('%d+')
      redis:setex("bot2maxlink", tonumber(Time), true)
    else
      redis:srem("bot2waitelinks", i.link)
    end
  end
  function find_link(text)
    if text:match("https://telegram.me/joinchat/%S+") or text:match("https://t.me/joinchat/%S+") or text:match("https://telegram.dog/joinchat/%S+") then
      local text = text:gsub("t.me", "telegram.me")
      local text = text:gsub("telegram.dog", "telegram.me")
      for link in text:gmatch("(https://telegram.me/joinchat/%S+)") do
        if not redis:sismember("bot2alllinks", link) then
          redis:sadd("bot2waitelinks", link)
          redis:sadd("bot2alllinks", link)
        end
      end
    end
  end
  function add(id)
    local Id = tostring(id)
    if not redis:sismember("bot2all", id) then
      if Id:match("^(%d+)$") then
        redis:sadd("bot2users", id)
        redis:sadd("bot2all", id)
      elseif Id:match("^-100") then
        redis:sadd("bot2supergroups", id)
        redis:sadd("bot2all", id)
      else
        redis:sadd("bot2groups", id)
        redis:sadd("bot2all", id)
      end
    end
    return true
  end
  function rem(id)
    local Id = tostring(id)
    if redis:sismember("bot2all", id) then
      if Id:match("^(%d+)$") then
        redis:srem("bot2users", id)
        redis:srem("bot2all", id)
      elseif Id:match("^-100") then
        redis:srem("bot2supergroups", id)
        redis:srem("bot2all", id)
      else
        redis:srem("bot2groups", id)
        redis:srem("bot2all", id)
      end
    end
    return true
  end
  function send(chat_id, msg_id, text)
    tdcli_function ({
          ID = "SendMessage",
          chat_id_ = chat_id,
          reply_to_message_id_ = msg_id,
          disable_notification_ = 1,
          from_background_ = 1,
          reply_markup_ = nil,
          input_message_content_ = {
            ID = "InputMessageText",
            text_ = text,
            disable_web_page_preview_ = 1,
            clear_draft_ = 0,
            entities_ = {},
            parse_mode_ = {ID = "TextParseModeHTML"},
          },
          }, dl_cb, nil)
    end
    get_admin()
    function tdcli_update_callback(data)
      if data.ID == "UpdateNewMessage" then
        if not redis:get("bot2maxlink") then
          if redis:scard("bot2waitelinks") ~= 0 then
            local links = redis:smembers("bot2waitelinks")
            for x,y in pairs(links) do
              if x == 11 then redis:setex("bot2maxlink", 60, true) return end
              tdcli_function({ID = "CheckChatInviteLink",invite_link_ = y},process_link, {link=y})
              end
            end
          end
          if not redis:get("bot2maxjoin") then
            if redis:scard("bot2goodlinks") ~= 0 then 
              local links = redis:smembers("bot2goodlinks")
              for x,y in pairs(links) do
                local sgps = redis:scard("bot2supergroups")
                local maxsg = redis:get("bot2maxsg") or 200
                if tonumber(sgps) < tonumber(maxsg) then
                  tdcli_function({ID = "ImportChatInviteLink",invite_link_ = y},process_join, {link=y})
                    if x == 4 then redis:setex("bot2maxjoin", 60, true) return end
                  end
                end
              end
            end
            local msg = data.message_
            local bot_id = redis:get("bot2id") or get_bot()
            if (msg.sender_user_id_ == 777000 or msg.sender_user_id_ == 178220800) then
              for k,v in pairs(redis:smembers('bot2admin')) do
                tdcli_function({
                      ID = "ForwardMessages",
                      chat_id_ = v,
                      from_chat_id_ = msg.chat_id_,
                      message_ids_ = {[0] = msg.id_},
                      disable_notification_ = 0,
                      from_background_ = 1
                      }, dl_cb, nil)
                end
              end
              if tostring(msg.chat_id_):match("^(%d+)") then
                if not redis:sismember("bot2all", msg.chat_id_) then
                  redis:sadd("bot2users", msg.chat_id_)
                  redis:sadd("bot2all", msg.chat_id_)
                end
              end 
              add(msg.chat_id_)
              if msg.date_ < os.time() - 150 then
                return false
              end 
              if msg.content_.ID == "MessageText" then
                local text = msg.content_.text_
                local matches
                find_link(text)
                if is_adigram(msg) then 
                  if text:match("([Tt]ime) (%d+)") or text:match ("(زمان) (%d+)") then
                    local matches = text:match("%d+")
                    redis:set('bot2delay', matches)
                    return send(msg.chat_id_, msg.id_, "<code>⏲زمان ارسال بین گروه به :\n🔹 "..tostring(matches).." 🔸\nثانیه تنظیم شد✔️\n➖➖➖➖➖\n🔖ربات پس از از هر ارسال به گروه برای گروه بعدی به مدت "..tostring(matches).." ثانیه صبر میکند و سپس ارسال میکند\n➖➖➖➖\n⚠️توجه در این مدت ربات پاسخی به دستورات شما نمیدهد و پس از پایان ارسال پیام اماده به کار برای شما ارسال میشود\n➖➖➖\n</code>🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                  elseif text:match("([Mm]axgap) (%d+)") or text:match("(حداکثر سوپرگروه) (%d+)") then
                    local matches = text:match("%d+")
                    redis:set('bot2maxsg', matches)
                    return send(msg.chat_id_, msg.id_, "<code>🚦حداکثر گروه های تبچی تنظیم شد به :\n🔹 "..tostring(matches).." 🔸\n➖➖➖➖\n🔖زمانی که گروه های ربات به  "..tostring(matches).." \n گروه رسید ربات دیگر از طریق لینک وارد گروه ها نمیشود و گروه های ربات افزایش نمی یابد.</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                  elseif text:match("([Ss]etowner) (%d+)") or text:match("(افزودن مدیر) (%d+)") then
                    local matches = text:match("%d+")
                    if redis:sismember('bot2admin', matches) then
                      return send(msg.chat_id_, msg.id_, "<code>فرد از قبل مدیر ربات بوده است✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                    elseif redis:sismember('bot2mod', msg.sender_user_id_) then
                      return send(msg.chat_id_, msg.id_, "<code>شما مدیر ربات نیستید</code>")
                    else
                      redis:sadd('bot2admin', matches)
                      redis:sadd('bot2mod', matches)
                      return send(msg.chat_id_, msg.id_, "<code>🤖فرد به مدیریت ربات ارتقا یافت\n➖➖➖\nاکنون میتواند ربات را مدیریت کند✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                    end
                  elseif text:match("([Rr]emowner) (%d+)") or text:match("(حذف مدیر) (%d+)") then
                    local matches = text:match("%d+")
                    if redis:sismember('bot2mod', msg.sender_user_id_) then
                      if tonumber(matches) == msg.sender_user_id_ then
                        redis:srem('bot2admin', msg.sender_user_id_)
                        redis:srem('bot2mod', msg.sender_user_id_)
                        return send(msg.chat_id_, msg.id_, "<code>فرد از قبل مدیر ربات نبوده است</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                      end
                      return send(msg.chat_id_, msg.id_, "<code>شما مدیر ربات نیستید</code>")
                    end
                    if redis:sismember('bot2admin', matches) then
                      if  redis:sismember('bot2admin'..msg.sender_user_id_ ,matches) then
                        return send(msg.chat_id_, msg.id_, "<code>You dont have permission to kill your boss.</code>")
                      end
                      redis:srem('bot2admin', matches)
                      redis:srem('bot2mod', matches)
                      return send(msg.chat_id_, msg.id_, "<code>فرد از لیست مدیر های ربات حذف شد✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                    end
                    return send(msg.chat_id_, msg.id_, "<code>فرد از قبل مدیر ربات نبوده است</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                  elseif text:match("[Rr]efresh") or text:match("بازرسی") then
                    local list = {redis:smembers("bot2supergroups"),redis:smembers("bot2groups")}
                    tdcli_function({
                          ID = "SearchContacts",
                          query_ = nil,
                          limit_ = 999999999
                          }, function (i, adigram)
                          redis:set("bot2contacts", adigram.total_count_)
                        end, nil)
                      for i, v in pairs(list) do
                        for a, b in pairs(v) do 
                          tdcli_function ({
                                ID = "GetChatMember",
                                chat_id_ = b,
                                user_id_ = bot_id
                                }, function (i,adigram)
                                if  adigram.ID == "Error" then rem(i.id) 
                                end
                              end, {id=b})
                          end
                        end
                        return send(msg.chat_id_, msg.id_, "<code>امار ربات در حال بروز رسانی و برسی دوباره است✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                      elseif text:match("callspam") then
                        tdcli_function ({
                              ID = "SendBotStartMessage",
                              bot_user_id_ = 178220800,
                              chat_id_ = 178220800,
                              parameter_ = 'start'
                              }, dl_cb, nil) 
                        elseif text:match("reload") or text:match("ریست") then
                          return reload(msg.chat_id_,msg.id_)
                        elseif text:match("(markread) (.*)") or text:match("(بازدید) (.*)") then
                          local matches = text:match("markread (.*)") or text:match("بازدید (.*)")
                          if matches == "on" or matches == "روشن" then
                            redis:set("bot2markread", true)
                            return send(msg.chat_id_, msg.id_, "<code>بازدید روشن شد✔️\nاز این پس تمام پیام ها تیک دوم رو دریافت میکنند👁</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                          elseif matches == "off" or matches == "خاموش" then
                            redis:del("bot2markread")
                            return send(msg.chat_id_, msg.id_, "<code>بازدید خاموش شد✔️\nاز این پس هیچ پیامی تیک دوم رو دریافت نمیکند👁</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad️")
                          end
                        elseif text:match("stat") or text:match("امار") then
                          local gps = redis:scard("bot2groups")
                          local sgps = redis:scard("bot2supergroups")
                          local usrs = redis:scard("bot2users")
                          local links = redis:scard("bot2savedlinks")
                          local glinks = redis:scard("bot2goodlinks")
                          local wlinks = redis:scard("bot2waitelinks")
                          local s = redis:get("bot2maxjoin") and redis:ttl("bot2maxjoin") or 0
                          local ss = redis:get("bot2maxlink") and redis:ttl("bot2maxlink") or 0
                          local delay = redis:get("bot2delay") or 5
                          local maxsg = redis:get("bot2maxsg") or 200

                          local text = 
[[<b>🚩 امار ربات تبچی 🚩</b>
➖➖➖➖➖
<code>📍تعداد چت خصوصی : </code>
🔹 <b>]] .. tostring(usrs) .. [[</b><code> چت</code> 🔸

<code>🎲تعداد گروه ها: </code>
🔹 <b>]] .. tostring(gps) .. [[</b><code> گروه</code> 🔸

<code>🏁تعداد سوپرگروه ها: </code>
🔹 <b>]] .. tostring(sgps) .. [[</b><code> سوپرگروه</code> 🔸

<code>📲لینک های ذخیره شده: </code>
🔹 <b>]] .. tostring(links)..[[</b><code> لینک</code> 🔸

<code>🎯تعداد لینک های استفاده شده: </code>
🔹 <b>]] .. tostring(glinks)..[[</b><code> لینک</code> 🔸

<code>👾تعداد لینک های در انتظار تایید: </code>
🔹 <b>]] .. tostring(wlinks)..[[</b><code> لینک</code> 🔸

<code>⏱تا عضویت بعدی با لینک: </code>
🔹 <b>]] .. tostring(s)..[[</b><code> ثانیه</code> 🔸

<code>⏰تا تایید لینک بعدی: </code>
🔹 <b>]] .. tostring(ss)..[[</b><code> ثانیه</code> 🔸

<code>⏲زمان فاصله بین ارسال: </code>
🔹 <b>]] .. tostring(delay)..[[</b><code> ثانیه</code> 🔸

<code>🚦حداکثر سوپرگروه ها: </code>
🔹 <b>]] .. tostring(maxsg)..[[</b><code> سوپرگروه</code> 🔸

<code>➖➖➖➖</code>
🚀کانال ما : @Os3tad_team
😉سازنده : @Os3tad]]

                          return send(msg.chat_id_, 0, text)
                        elseif (text:match("send") or text:match("ارسال") and msg.reply_to_message_id_ ~= 0) then
                          local list = redis:smembers("bot2supergroups") 
                          local id = msg.reply_to_message_id_

                          local delay = redis:get("bot2delay") or 5
                          local sgps = redis:scard("bot2supergroups")
                          local esttime = ((tonumber(delay) * tonumber(sgps)) / 60) + 1
                          send(msg.chat_id_, msg.id_, "<code>🏁تعداد سوپرگروه ها : " ..tostring(sgps).. "\n⏰فاصله بین ارسال هر گروه : " ..tostring(delay).. " ثانیه" .."\n⏱مدت زمان تا اتمام ارسال : " ..tostring(math.floor(esttime)).. " دقیقه" .. "\nدر حال ارسال به همه ی سوپرگروه ها✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                          for i, v in pairs(list) do
                            sleep(0)
                            tdcli_function({
                                  ID = "ForwardMessages",
                                  chat_id_ = v,
                                  from_chat_id_ = msg.chat_id_,
                                  message_ids_ = {[0] = id},
                                  disable_notification_ = 1,
                                  from_background_ = 1
                                  }, dl_cb, nil)
                            end
                            send(msg.chat_id_, msg.id_, "<code>پیام ارسال شد برای : " ..tostring(sgps).. " سوپرگروه.\nربات دوباره اماده به کار شد✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                          elseif text:match("send (.*)") or text:match("ارسال (.*)") then
                            local matches = text:match("send (.*)") or text:match("ارسال (.*)")
                            local dir = redis:smembers("bot2supergroups")
                            local delay = redis:get("bot2delay") or 5
                            local sgps = redis:scard("bot2supergroups")
                            local esttime = ((tonumber(delay) * tonumber(sgps)) / 60) + 1
                          send(msg.chat_id_, msg.id_, "<code>🏁تعداد سوپرگروه ها : " ..tostring(sgps).. "\n⏰فاصله بین ارسال هر گروه : " ..tostring(delay).. " ثانیه" .."\n⏱مدت زمان تا اتمام ارسال : " ..tostring(math.floor(esttime)).. " دقیقه" .. "\nدر حال ارسال به همه ی سوپرگروه ها✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                            for i, v in pairs(dir) do
                              sleep(0)
                              tdcli_function ({
                                    ID = "SendMessage",
                                    chat_id_ = v,
                                    reply_to_message_id_ = 0,
                                    disable_notification_ = 0,
                                    from_background_ = 1,
                                    reply_markup_ = nil,
                                    input_message_content_ = {
                                      ID = "InputMessageText",
                                      text_ = matches,
                                      disable_web_page_preview_ = 1,
                                      clear_draft_ = 0,
                                      entities_ = {},
                                      parse_mode_ = nil
                                    },
                                    }, dl_cb, nil)
                              end
                            send(msg.chat_id_, msg.id_, "<code>پیام ارسال شد برای : " ..tostring(sgps).. " سوپرگروه.\nربات دوباره اماده به کار شد✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                            elseif text:match('(setname) (.*) (.*)') or text:match('(تنظیم نام) (.*) (.*)') then
                              local fname, lname = text:match('setname "(.*)" (.*)') or text:match('تنظیم نام "(.*)" (.*)')
                              tdcli_function ({
                                    ID = "ChangeName",
                                    first_name_ = fname,
                                    last_name_ = lname
                                    }, dl_cb, nil)
                                return send (msg.chat_id_, msg.id_, "<code>نام با موفقیت تغییر کرد✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                              elseif text:match("(setusername) (.*)") or text:match("(تنظیم یوزرنیم) (.*)") then
                                local matches = text:match("setusername (.*)") or text:match("تنظیم یوزرنیم (.*)")
                                tdcli_function ({
                                      ID = "ChangeUsername",
                                      username_ = tostring(matches)
                                      }, dl_cb, nil)
                                  return send (msg.chat_id_, msg.id_, "<code>یوزرنیم با موفقیت تغییر کرد✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                                elseif text:match("(delusername)") or text:match("(حذف یوزرنیم)") then
                                  tdcli_function ({
                                        ID = "ChangeUsername",
                                        username_ = ""
                                        }, dl_cb, nil)
                                    return send (msg.chat_id_, msg.id_, "<code> یوزرنیم ربات حذف شد✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                                  elseif text:match("(say) (.*)") or text:match("(بگو) (.*)") then
                                    local matches = text:match("say (.*)") or text:match("بگو (.*)")
                                    return send(msg.chat_id_, 0, matches)
                                  elseif text:match("(addallgap) (%d+)") or text:match("(اضافه کردن) (%d+)") then
                                    local matches = text:match("%d+")
                                    local list = {redis:smembers("bot2groups"),redis:smembers("bot2supergroups")}
                                    for a, b in pairs(list) do
                                      for i, v in pairs(b) do 
                                        tdcli_function ({
                                              ID = "AddChatMember",
                                              chat_id_ = v,
                                              user_id_ = matches,
                                              forward_limit_ =  50
                                              }, dl_cb, nil)
                                        end	
                                      end
                                      return send (msg.chat_id_, msg.id_, "<code>کاربر به تمام سوپر گروه های من دعوت شد✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                                    elseif (text:match("(online)") and not msg.forward_info_) or (text:match("(انلاینی)") and not msg.forward_info_) then
                                      return tdcli_function({
                                            ID = "ForwardMessages",
                                            chat_id_ = msg.chat_id_,
                                            from_chat_id_ = msg.chat_id_,
                                            message_ids_ = {[0] = msg.id_},
                                            disable_notification_ = 0,
                                            from_background_ = 1
                                            }, dl_cb, nil)
                                      elseif text:match("([Hh]elp)") then
                                        local txt = '<code>🚩راهنمای دستورات تبچی 🚩</code>\n#english\n➖➖➖➖➖\n\n/stats\n🚦دریافت امار ربات\n\n/time [زمان]\n💭فاصله بین ارسال در هر گروه را تایین کنید\nپیش نهاد ما به شما برای جلوگیری از حذف اکانت ربات توسط تلگرام تنظیم زمان به 5 ثانیه میباشد\n\n/maxgap [عدد]\n💭حد اکثر گروه های تبچی خود را تایین کنید پیش نهاد ما 400 گروه است\n\n/setowner [ریپلای | ایدی]\n💭تنظیم فرد به عنوان مدیر ربات🤖\n\n/remowner [ریپلای | ایدی]\n💭جذف فرد از مقام مدیر ربات😦\n\n/refresh\n💭بارگزاری مجدد امار ربات\nبهتر است در روز بیش از یک بار استفاده نشود🔃\n\n/reload\n💭ریست کردن و بارگزاری مجدد کامل ربات حد المقدور استفاده شود☺️\n\n/markread [on | off]\n💭روشن  و خاموش کردن بازدید[تیک دوم] برای پیام ها👁\n\n/send [ریپلای | متن]\n💭فوروارد یا ارسال پیام به همه ی سوپر گروه ها\nمیتوانید روی پیام ریپلای کنید یا متن خود را قرار دهید✨\n\n/setname [نام اول نام دوم]\n💭تنظیم نام ربات🙄\nمثال : 🔸 setname jiji mohammadrezajiji 🔹\n\n/setusername [متن]\n💭تنظیم یوزرنیم ربات💫\n\n/delusername\n💭حذف یوزرنیم ربات🗑\n\n/say [متن]\n💭گفتن کلمه مورد نظر توسط ربات فقط در چتی که دستور داده شود✔️\n\n/online\n💭اطمینان از انلاین بودن ربات😃\n\n/addallgap [ایدی]\n💭اضافه کردن فرد به همه ی سوپر گروه های ربات\n🔸برای افزودن ربات api کافیست ان را استارت و سپس شناسه ابتدای توکن رو به جای ایدی وارد کنید🔹\n\n➖➖➖➖\n🔹ربات دارای دستورات فارسی نیز هست که شما میتوانید با نوشتن [راهنما] ان را دریافت کنید\n\n🔸شما میتوانید در ابتدای دستورات به جای [/] از [!] , [#] نیز استفاده کنید یا اصلا بدون علامت استفاده کنید🎯\n\n⚠️ربات به صورت خودکار وارد لینک ها میشود و همچنین افزودن مخاطب غیر فعال میباشد و درصورتی که مخاطب توسط شما ارسال شود [شیر شود] ربات ان را به لیست مخاطب ها اضافه میکند\n➖➖➖\n📍ادرس گیت هاب سورس :https://github.com/TitanTeams/tabchi\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad'
                                        return send(msg.chat_id_,msg.id_, txt)
                                      elseif text:match("(راهنما)") then
                                        local txt = '<code>🚩راهنمای دستورات تبچی 🚩</code>\n#persian\n➖➖➖➖➖\n\nامار\n🚦دریافت امار ربات\n\nزمان [عدد]\n💭فاصله بین ارسال در هر گروه را تایین کنید\nپیش نهاد ما به شما برای جلوگیری از حذف اکانت ربات توسط تلگرام تنظیم زمان به 5 ثانیه میباشد\n\nحداکثر سوپرگروه [عدد]\n💭حد اکثر گروه های تبچی خود را تایین کنید پیش نهاد ما 400 گروه است\n\nافزودن مدیر [ریپلای | ایدی]\n💭تنظیم فرد به عنوان مدیر ربات🤖\n\nحذف مدیر [ریپلای | ایدی]\n💭جذف فرد از مقام مدیر ربات😦\n\nبازرسی\n💭بارگزاری مجدد امار ربات\nبهتر است در روز بیش از یک بار استفاده نشود🔃\n\nریست\n💭ریست کردن و بارگزاری مجدد کامل ربات حد المقدور استفاده شود☺️\n\nبازدید [خاموش | روشن]\n💭روشن  و خاموش کردن بازدید[تیک دوم] برای پیام ها👁\n\nارسال [ریپلای | متن]\n💭فوروارد یا ارسال پیام به همه ی سوپر گروه ها\nمیتوانید روی پیام ریپلای کنید یا متن خود را قرار دهید✨\n\nتنظیم نام [نام اول نام دوم]\n💭تنظیم نام ربات🙄\nمثال : 🔸 تنظیم نام jiji mohammadrezajiji 🔹\n\nتنظیم یوزرنیم [متن]\n💭تنظیم یوزرنیم ربات💫\n\nحذف یوزرنیم\n💭حذف یوزرنیم ربات🗑\n\nبگو [متن]\n💭گفتن کلمه مورد نظر توسط ربات فقط در چتی که دستور داده شود✔️\n\nانلاینی\n💭اطمینان از انلاین بودن ربات😃\n\nاضافه کردن [ایدی]\n💭اضافه کردن فرد به همه ی سوپر گروه های ربات\n🔸برای افزودن ربات api کافیست ان را استارت و سپس شناسه ابتدای توکن رو به جای ایدی وارد کنید🔹\n\n➖➖➖➖\n🔹ربات دارای دستورات انگلیسی نیز هست که شما میتوانید با نوشتن [help] ان را دریافت کنید\n\n⚠️ربات به صورت خودکار وارد لینک ها میشود و همچنین افزودن مخاطب غیر فعال میباشد و درصورتی که مخاطب توسط شما ارسال شود [شیر شود] ربات ان را به لیست مخاطب ها اضافه میکند\n➖➖➖\n📍ادرس گیت هاب سورس :https://github.com/TitanTeams/tabchi\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad'
                                        return send(msg.chat_id_,msg.id_, txt)
                                      end
                                    end		
                                  elseif msg.content_.ID == "MessageContact" then
                                    if redis:sismember("bot2admin",msg.sender_user_id_) then
                                      local first = msg.content_.contact_.first_name_ or "-"
                                      local last = msg.content_.contact_.last_name_ or "-"
                                      local phone = msg.content_.contact_.phone_number_
                                      local id = msg.content_.contact_.user_id_
                                      tdcli_function ({
                                            ID = "ImportContacts",
                                            contacts_ = {[0] = {
                                                phone_number_ = tostring(phone),
                                                first_name_ = tostring(first),
                                                last_name_ = tostring(last),
                                                user_id_ = id
                                              },
                                            },
                                            }, dl_cb, nil)
                                        return send (msg.chat_id_, msg.id_, "<code>مخاطب به لیست مخاطب های من افزوده شد✔️</code>\n➖➖➖\n🚀کانال ما : @Os3tad_team\n😉سازنده : @Os3tad")
                                      end
                                    elseif msg.content_.ID == "MessageChatDeleteMember" and msg.content_.id_ == bot_id then
                                      return rem(msg.chat_id_)
                                    elseif msg.content_.ID == "MessageChatJoinByLink" and msg.sender_user_id_ == bot_id then
                                      return add(msg.chat_id_)
                                    elseif msg.content_.ID == "MessageChatAddMembers" then
                                      for i = 0, #msg.content_.members_ do
                                        if msg.content_.members_[i].id_ == bot_id then
                                          add(msg.chat_id_)
                                        end
                                      end
                                    elseif msg.content_.caption_ then
                                      return find_link(msg.content_.caption_)
                                    end
                                    if redis:get("bot2markread") then
                                      tdcli_function ({
                                            ID = "ViewMessages",
                                            chat_id_ = msg.chat_id_,
                                            message_ids_ = {[0] = msg.id_} 
                                            }, dl_cb, nil)
                                      end
                                    elseif data.ID == "UpdateOption" and data.name_ == "my_id" then
                                      tdcli_function ({
                                            ID = "GetChats",
                                            offset_order_ = 9223372036854775807,
                                            offset_chat_id_ = 0,
                                            limit_ = 20
                                            }, dl_cb, nil)
                                      end
                                    end

