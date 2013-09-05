module BrowserHelper

  def placeholder(label=nil)
    "placeholder='#{label}'" #if platform == 'apple'
  end

  def platform
    System::get_property('platform').downcase
  end

  def selected(option_value,object_value)
    "selected=\"yes\"" if option_value == object_value
  end

  def checked(option_value,object_value)
    "checked=\"yes\"" if option_value == object_value
  end

  def is_bb6
    platform == 'blackberry' && (System::get_property('os_version').split('.')[0].to_i >= 6)
  end
  def putcms
     "<!-- AMoAd Zone: [インライン_ユーティリティ_TOPフッダー_ユーティリティ_ながのバスサーチ_ケンコバ] -->
      <div class=\"ad_frame sid_62056d310111552c2d5e055b6b46aa5b36705a22ed458894b0044030231693c8 container_div color_#0000CC-#444444-#FFFFFF-#0000FF-#009900 sp wv\"></div>"
      #<div class=\"ad_frame sid_b933b6ed285c118eb0074fa0b76d8116d7d9ac661a788926aa4b32dfc7e842cd container_div color_#0000CC-#444444-#FFFFFF-#0000FF-#009900 sp wv\"></div>"

  end

  def putimobileCms
       "<!-- i-mobile for SmartPhone client script -->
    <script type=\"text/javascript\">
      imobile_tag_ver = \"0.2\"; 
      imobile_pid = \"18258\"; 
      imobile_asid = \"86292\"; 
      imobile_type = \"overlay\";
    </script>
    <script type=\"text/javascript\" src=\"http://spad.i-mobile.co.jp/script/adssp.js?20110215\"></script>"
  end  
  
  def navifooter(strorstp)
        "<div data-role=\"navbar\">
            <ul>
                <li><a onClick=\"document.location ='" + url_for( :action => :geolication , :query =>{:strorstp => strorstp}) + "'\">地図からえらぶ</a></li>
                <li><a onClick=\"document.location ='" + url_for( :action => :line_btslist , :query =>{:strorstp => strorstp}) + "'\">路線からえらぶ</a></li>
                <li><a onClick=\"document.location ='" + url_for( :action => :busstplist , :query =>{:strorstp => strorstp}) + "'\">一覧からえらぶ</a></li>
            </ul>
        </div>
        <a href=\"" + (url_for :action => :index ) + "\" class=\"ui-btn-left\" data-icon=\"arrow-l\" data-direction=\"reverse\">
              戻る
        </a>"
  end
  
  def setthemes
    "data-theme=\"d\""
  end

end
