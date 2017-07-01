require "vifi/version"
require 'willow_run'
require 'chart_js'

module Vifi

  def self.build_chart
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

  def self.build_updater(source: '/update_source', chart_obj: 'line_chart')
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

end
