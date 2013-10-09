require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'json'

# バス検索コントローラ
class BusSerchController < Rho::RhoController
 include BrowserHelper

  # トップメニュー
  def index
    
    rirekihash = Hash.new
    rirekihash["startname"] = ""
    rirekihash["stopname"] = ""
    rirekihash["linename"] = ""
    
    #Rireki.delete_all()
    @rireki = Rireki.find(:first)
    Rireki.create(rirekihash) if not @rireki
    @rireki = Rireki.find(:first)

    if @params["strorstp"] == "strbts" then
       $session[:startbts] = @params["bts"]
    elsif  @params["strorstp"] == "stpbts" then
       $session[:stpbts] = @params["bts"]
    end
    @startbts = $session[:startbts] || @rireki.startname
    @stptbts = $session[:stpbts] || @rireki.stopname
    $session[:time] = Time.now.strftime("%H:%M")
    render
  end
  
  def info
  end

  def geolication
    @strorstp = @params["strorstp"]
    #緯度の取得
    @lat = GeoLocation.latitude
    #経度の取得
    @lng = GeoLocation.longitude

    geturl = "/busstops/result_bts_lines"
      
    if result_session("busstpgpslist",geturl) ["status"] == "ok"
      # HTTPのbodyには、JSON解析されたHashの値が入る。
      body = result_session("busstpgpslist",geturl) ["body"] 
      busstops = body["busstops"]
      @busary = Array.new
      busstops.each {|bsp|
         @busary.push([ bsp["busstopname"].to_s,
                        bsp["gps1"].to_s,
                        bsp["gps2"].to_s,
                        bsp["linenames"].join("<br>")
                      ])
      }
    end
    render
  end
    
  def busstplist
    @strorstp = @params["strorstp"]
    geturl = "/busstops/result"

    if result_session("busstplist",geturl)["status"] == "ok"
      # HTTPのbodyには、JSON解析されたHashの値が入る。
      body = result_session("busstplist",geturl)["body"]

      busstops = body["bussstops"]
      @busary = Array.new
      busstops.each {|bsp|
         @busary.push([ bsp["bussstop"]["busstpname"].to_s,
                        bsp["bussstop"]["gps1"],
                        bsp["bussstop"]["gps2"],
                      ])
      }
      

      render :back => url_for(:action => :index)
    else
      Alert.show_popup("データが取得できませんでした。")
      redirect :action => :index
    end
  end

  def line_btslist
   p @params 
    @strorstp = @params["strorstp"]

    geturl = "/busstops/result_lines_bts"
    if result_session("busstplist_line",geturl)["status"] == "ok"
      # HTTPのbodyには、JSON解析されたHashの値が入る。
      body = result_session("busstplist_line",geturl)["body"]

      line_bts = body["line_bts"]
      @linehash = Hash.new
      line_bts.each_pair { |key , bts|
              btsary = Array.new
              bts.each { |bt|
                      btsary.push(bt["diagram"]["busstpname"].to_s)
              }
              @linehash[key.to_s] = btsary
      }
      render :back => url_for(:action => :index)
    else
      Alert.show_popup("データが取得できませんでした。")
      redirect :action => :index
    end
  end
  # JSONファイルをサーバから取得して、表示する。
  def get_json

    @rireki = Rireki.find(:first)
    @rireki.update_attributes({"startname"=>@params['start_busstopnm'].to_s,"stopname"=>@params['arrival_busstopnm'].to_s,"linename"=>"ss"})
    
    strbus = Rho::RhoSupport.url_encode(@params['start_busstopnm'].to_s)
    avlbus = Rho::RhoSupport.url_encode(@params['arrival_busstopnm'].to_s)

    timepara = @params['arrordep'].to_s + "_datetime=20121111" + @params['timefield'].to_s.gsub(/:/,"")
    p strbus
    p avlbus
    p timepara

    geturl = "/diagrams/result?start_busstopnm=#{strbus}&arrival_busstopnm=#{avlbus}&#{timepara}"
    if @params['weekends'] == "true" then
        geturl << "&weekend=1"
    end
    if rest_request(geturl)["status"] == "ok"
      # HTTPのbodyには、JSON解析されたHashの値が入る。
      body = rest_request(geturl)["body"]
 
      busstops = body["diagrams"]
      @busary = Array.new
      busstops.each {|bsp|
         @busary.push([ bsp["diagram"]["busstpname"].to_s,
                        bsp["diagram"]["avltime"].to_s.insert(-3,":"),
                        bsp["diagram"]["linename"].to_s
                      ])
      }
      

      render :back => url_for(:action => :index)
    else
      Alert.show_popup("データが取得できませんでした。")
      redirect :action => :index
    end
  end
  
  
  #タイムピッカー機能の呼び出し
  def choose
    #タイムピッカー機能の呼び出し・コールバックの設定
    DateTimePicker.choose(url_for(:action => :choose_callback),
                          #タイムピッカー画面のタイトルを指定
                          '選択して下さい',
                          #時間の初期値
                          Time.new,
                          #タイムピッカーの種類を指定
                          # 0  =>  日付・時間
                          # 1  =>  日付
                          # 2  =>  時間
                          @params['flg'].to_i,
                          #コールバックに渡す値をを設定
                          Marshal.dump(@params['flg'])
                         )
    redirect :action => :index
  end

  #タイムピッカーのコールバック(時間を選び終ると入る)
  def choose_callback
    if @params['status'] == 'ok'
      #resultに入っている文字列を時間に変換(ユーザーが選んだ時間・日付が取得できる)
      time = Time.at(@params['result'].to_i)
      #値をロードする
      flg = Marshal.load(@params['opaque'])
      #flgの値によって出力するフォーマットを指定する
      case flg
      when "0" then
        format = '%F %T'
        #コントローラーから、フィールドへ値をセットするjavascriptの呼び出し
        WebView.execute_js('Time_Picker_Set("' + time.strftime(format) + '");')
        #画面が更新されないように、ここで処理を終了させる
        return
      when "1"
        format = '%F'
      when "2"
        format = '%T'
      else
        format = '%F %T'
      end
        format = '%T'
        WebView.execute_js('Time_Picker_Set("' + time.strftime("%H:%M") + '");')
        return
      Alert.show_popup(
        :message => "#{time.strftime(format)}",
        :title => "あなたが選択した時間",
        :buttons => ["了解"]
      )
    end
    WebView.navigate(url_for(:action => :index))
  end
  
private
    def rest_request(geturl)
      host = "http://www9264ui.sakura.ne.jp"
      #host = "http://localhost:3000"
      @http ||= begin 
        Rho::AsyncHttp.get(
           # アクセス時にヘッダ情報を日本語にする。
           :headers => {"Accept-Language" => "ja"},
           :url => host + geturl
        )
      end
    end
    
    def result_session(name,geturl)
      $session[name] ||= rest_request(geturl)
    end
end
