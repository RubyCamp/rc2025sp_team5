rm_pin1 = PWM.new(25) # 右モーターPIN1
rm_pin2 = PWM.new(26) # 右モーターPIN2

lm_pin1 = PWM.new(32) # 左モーターPIN1
lm_pin2 = PWM.new(33) # 左モーターPIN2
   
wlan = WLAN.new('STA')
wlan.connect("RubyCamp", "shimanekko")  # 自分の環境に合わせて設定．2.4GHz帯を使うこと．

puts wlan.ifconfig  # 全パラメタ
puts wlan.ip        # IP アドレス
puts wlan.mac       # MAC アドレス
   
if ( wlan.connected? ) #通信が確立していたら
    HTTP.get("http://192.168.6.25:3000/position?op=abs&x=500&y=100")
    HTTP.get("http://192.168.6.25:3000/angle?op=abs&value=180")
end

loop do
    if ( wlan.connected? ) #通信が確立していたら
       # 左右モーター出力30%正回転
        lm_pin1.duty(30)
        lm_pin2.duty(00)
        rm_pin1.duty(30)
        rm_pin2.duty(0)
        HTTP.get("http://192.168.6.25:3000/position?op=diff&x=0&y=1") 
        if (res=="turn_right")
            lm_pin1.duty(0)
            lm_pin2.duty(0)
            rm_pin1.duty(0)
            rm_pin2.duty(0)
            sleep(0.5)
            lm_pin1.duty(0)
            lm_pin2.duty(30)
            rm_pin1.duty(30)
            rm_pin2.duty(0)
            sleep(1.75)
            HTTP.get("http://192.168.6.25:3000/angle?op=diff&&value=90") 
        else(res=="turn_left")
            lm_pin1.duty(0)
            lm_pin2.duty(0)
            rm_pin1.duty(0)
            rm_pin2.duty(0)
            sleep(0.5)
            lm_pin1.duty(30)
            lm_pin2.duty(0)
            rm_pin1.duty(0)
            rm_pin2.duty(30)
            sleep(1.75)
            HTTP.get("http://192.168.6.25:3000/angle?op=diff&&value=-90") 
        end
        puts res
        sleep(0.1)
    end
end
   