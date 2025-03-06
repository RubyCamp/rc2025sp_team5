i2c = I2C.new()             # I2Cシリアルインターフェース初期化
vl53l0x = VL53L0X.new(i2c)  # 距離センサー（VL53L0X）
vl53l0x.set_timeout(500)   
servo27 = PWM.new(27, timer:2, channel:5, frequency:50)

rm_pin1 = PWM.new(25,timer:0,channel:1) # 右モーターPIN1
rm_pin2 = PWM.new(26,timer:0,channel:2) # 右モーターPIN2

lm_pin1 = PWM.new(32,timer:1,channel:3) # 左モーターPIN1
lm_pin2 = PWM.new(33,timer:1,channel:4) # 左モーターPIN2
flg=0
angle0=180
wlan = WLAN.new('STA')
wlan.connect("RubyCamp", "shimanekko")  # 自分の環境に合わせて設定．2.4GHz帯を使うこと．

puts wlan.ifconfig  # 全パラメタ
puts wlan.ip        # IP アドレス
puts wlan.mac       # MAC アドレス
   
if ( wlan.connected? ) #通信が確立していたら
    HTTP.get("http://192.168.6.25:3000/position?op=abs&x=750&y=90")
    HTTP.get("http://192.168.6.25:3000/angle?op=abs&value=180")
end

if vl53l0x.read_range_continuous_millimeters > 88
  servo27.pulse_width_us( 2000 )
else
  servo27.pulse_width_us( 1000 )
end

sleep 0.5
if !vl53l0x.init
  puts "initialize failed"
else
  vl53l0x.start_continuous(100)
    loop do
        if ( wlan.connected? ) #通信が確立していたら
           # 左右モーター出力30%正回転
            kyori=vl53l0x.read_range_continuous_millimeters
            puts kyori
            if(kyori<88)
                lm_pin1.duty(100)
                lm_pin2.duty(100)
                rm_pin1.duty(100)
                rm_pin2.duty(100)
                sleep(0.5)
                servo27.pulse_width_us( 1000 )
                sleep(1)
                if flg==0
                    flg=3
                end
            end
            
            lm_pin1.duty(100)
            lm_pin2.duty(67-flg)
            rm_pin1.duty(100)
            rm_pin2.duty(67-flg)
            sleep(0.1)
            
            if(angle0==180)
                res=HTTP.get("http://192.168.6.25:3000/position?op=diff&x=0&y=30") 
            elsif(angle0==270)
                res=HTTP.get("http://192.168.6.25:3000/position?op=diff&x=-30&y=0")
            else(angle0==90)
                res=HTTP.get("http://192.168.6.25:3000/position?op=diff&x=30&y=0")
            end
    
            if (res=="turn_left\x00")

                lm_pin1.duty(100)
                lm_pin2.duty(100)
                rm_pin1.duty(100)
                rm_pin2.duty(100)
                sleep(0.5)
                lm_pin1.duty(72)
                lm_pin2.duty(100)
                rm_pin1.duty(100)
                rm_pin2.duty(72)
                sleep(2.3)
                lm_pin1.duty(100)
                lm_pin2.duty(100)
                rm_pin1.duty(100)
                rm_pin2.duty(100)
                sleep(0.1)

                HTTP.get("http://192.168.6.25:3000/angle?op=diff&value=-90") 
                puts("turn_left")
                angle0=angle0-90
            elsif(res=="turn_right\x00")
                lm_pin1.duty(100)
                lm_pin2.duty(100)
                rm_pin1.duty(100)
                rm_pin2.duty(100)
                sleep(0.5)
                lm_pin1.duty(100)
                lm_pin2.duty(72)
                rm_pin1.duty(72)
                rm_pin2.duty(100)
                sleep(2.3)
                lm_pin1.duty(100)
                lm_pin2.duty(100)
                rm_pin1.duty(100)
                rm_pin2.duty(100)
                sleep(0.1)

                HTTP.get("http://192.168.6.25:3000/angle?op=diff&value=90") 
                puts("turn_right")
                angle0=angle0+90
                
            elsif(res=="stop\x00")

                lm_pin1.duty(100)
                lm_pin2.duty(100)
                rm_pin1.duty(100)
                rm_pin2.duty(100)
                sleep(0.1)
            elsif(res=="finish\x00")
                lm_pin1.duty(100)
                lm_pin2.duty(100)
                rm_pin1.duty(100)
                rm_pin2.duty(100)
                break;
            else
                puts "go"
            end
    
            sleep(0.03)
        end
    end
end
   