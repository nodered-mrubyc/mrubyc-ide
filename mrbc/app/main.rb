require 'sinatra'
require 'webrick'
require 'json'
require 'tempfile'
require 'open3'

set :bind, '0.0.0.0'

get '/' do
  "working..."
end

# TODO: バージョン情報を返す機能を実装する
get '/versions' do
    content_type :json
    a = ["2.0.1", "3.2.0"]
    a.to_json
end

# 動作確認用のエディタ
get "/editor" do
    erb :editor
end
 
# TODO: コンパイル部分を実装する
post '/compile' do
    @name = params[:name]
    @program = params[:program]
    @version = params[:version]
  
    mrbc_path = ""
    if @version=="3.2.0" then
      mrbc_path = "/bin/mrbc3.2.0"
    elsif @version=="2.0.1" then
      mrbc_path = "/bin/mrbc2.0.1"
    else
      mrbc_path = "/bin/mrbc3.2.0"    # デフォルトのコンパイラ
    end
  
    Tempfile.create([@name, '.rb']) do |f|
      #プログラムをtmpファイルに保存
      path = f.path
      fname = File.basename(path, '.*')
      f.puts @program
      f.rewind
  
      #tmpファイルのコンパイル
      cpcmd = "#{mrbc_path} #{path}"
      puts cpcmd
      @cpr, @cpe, @cps = Open3.capture3(cpcmd)
      #cpr:標準出力, cpe:標準エラー, cps:プロセス終了ステータス
  
      if @cpe.empty? then
        mrbpath = "/tmp/#{fname}.mrb"
        send_file(mrbpath, filename: "#{@name}.mrb") 
  
      else
        puts "Error"
        erb :error
      end
  
    end
end
