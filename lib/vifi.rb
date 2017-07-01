require 'willow_run'
require 'chart_js'
require 'sinatra/base'

class Vifi < Sinatra::Base

  def build_chart
    chart = ChartJS.line do
      data do
        labels []
        dataset WillowRun::Status.new.getinfo.ssid do
          color :random
          data []
        end
      end
    end
    chart.to_html
  end

  def build_updater(source: '/update_source', chart_obj: 'line_chart')
    # why not
    "<script>
      var source = new EventSource('#{source}');
      var json;
      source.onmessage = function(e) { 
        json = JSON.parse(e.data);
    #{chart_obj}.data.datasets[0].data.push(json.value);
    #{chart_obj}.data.labels.push(json.label);
    #{chart_obj}.update();
      };
    </script>
    "
  end

  set :bind, '0.0.0.0'
  set :port, 3141

  get "/update_source", provides: 'text/event-stream' do
    stream(:keep_open) do |out|
      data = Hash.new
      loop do
        data[:label] = Time.now.strftime("%r")
        data[:value] = WillowRun::Status.new.getinfo.agrctlrssi
        out << "data: #{data.to_json}" + "\r\n\n"
        sleep 2
      end
    end
  end

  get "/" do
    build_chart + build_updater
  end

end

require "vifi/version"
