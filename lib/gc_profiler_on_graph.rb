# encoding:utf-8
# GC Profiler On Graph
module GCProfilerOnGraph
  class Filter

    def self.after(controller)
      prof = GC::Profiler.result
      return nil if prof.empty?
      @body = controller.response.body
      add_gc_profiler_graphs
    end

    private
    def self.add_gc_profiler_graphs
      insert_graphs
    end

    def self.insert_graphs
      profile = parse_profile()
      script_html = <<-HTML
      <script type="text/javascript">
      window.onload = function() {
        var heap_graph = new html5jp.graph.vbar("heap_vbar");
        if(!heap_graph ) { return; }

        #{display_draw_heap_params(profile)}

        heap_graph.draw(items, params);


        var gctime_graph = new html5jp.graph.line("gctime_line");
        if(!gctime_graph ) { return; }

        #{display_draw_gctime_params(profile)}

        gctime_graph.draw(items, params);

        var stats_graph = new html5jp.graph.vbar("stats_vbar");
        if(!stats_graph ) { return; }

        #{display_draw_heap_stats_params}

        stats_graph.draw(items, params);
      };     
      </script>
      HTML
      canvas_html = <<-HTML
      <table><tr>
      <td colspan="3"><div><canvas width="1300" height="400" id="stats_vbar"></canvas></div></td>
      </tr><tr>
      <td><div><canvas width="500" height="400" id="heap_vbar"></canvas></div></td>
      <td><div><canvas width="500" height="400" id="gctime_line"></canvas></div></td>
      <td></td>
      </tr></table>
      HTML
      insert_text :before, /<\/head>/i, script_html
      insert_text :before, /<\/body>/i, canvas_html
    end

    def self.parse_profile
      prof = GC::Profiler.result
      res = {}
      profs = prof.split("\n")
      res[:invokes]= $1 if profs.shift[/(\d+)/]
      profs.shift
      profs.each do |col|
        rows = col.split(/\s+/)
        rows.shift
        %w(index invoke_time use_size total_size total_object gc_time).zip(rows).each do |key, value|
          res[key.to_sym] ||= []
          res[key.to_sym] << value.to_i
        end
      end
      return res
    end

    def self.display_draw_heap_params(profile)
      items = [
               "['used heap size', #{profile[:use_size].join(', ')}], ",
               "['free heap size', #{profile[:total_size].zip(profile[:use_size]).map{|t, u| t - u}.join(', ')}]",
              ].join
      res =  template_items items
      res += template_xy("['count', #{profile[:index].join(', ')}]", "['byte']")
    end

    def self.display_draw_gctime_params(profile)
      res =  template_items "['gc time', #{profile[:gc_time].join(', ')}]"
      res += template_xy("['count', #{profile[:index].join(', ')}]", "['time(msec)']")
    end

    def self.display_draw_heap_stats_params
      res = []
      stats = ObjectSpace.count_objects.reject!{|k, v| %w(TOTAL FREE).include? k.to_s }.sort_by{|e| e[1]}
      res = template_items "['object count', #{stats.map{|k,v| v}.join(', ')}]"
      res += template_xy(%Q!['type', "#{stats.map{|k, v| k}.join('", "')}"]!, "['object count']")
    end

    def self.template_items(cols)
      res = <<-HTML
      var items = [
        #{cols}
      ];
      HTML
    end

    def self.template_xy(x, y)
      res = <<-HTML
      var params = {
        x: #{x}, 
        y: #{y}
      };
      HTML
    end

    def self.insert_text(position, pattern, new_text)
      index = case pattern
              when Regexp
                if match = @body.match(pattern)
                  match.offset(0)[position == :before ? 0 : 1]
                else
                  @body.size
                end
              else
                pattern
              end
      @body.insert index, new_text
    end
  end
end
