describe "Parcels determining classes from files", :type => :system do
  context "with a widget with a non-guessable class name, but at the right point in its path" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        file 'views/foo/bar/baz.rb', %{
          path = [ "Vie", "oo", "Ba", "az" ]
          path[0] = path[0] + "ws"
          path[1] = "F" + path[1]
          path[2] = path[2] + "r"
          path[3] = "B" + path[3]

          (0..2).each do |index|
            module_name = path[0..index].join("::")
            eval("module \#{module_name}; end")
          end

          class_name = path.join("::")

          klass = Class.new(::Spec::Fixtures::WidgetBase) do
            css 'p { color: red; }'

            def content
              p 'hello!'
              end
          end

          mod = eval(path[0..-2].join("::"))
          mod.const_set(path[-1], klass)
        }

          # eval("class \#{class_name} < ::Spec::Fixtures::WidgetBase; css 'p { color: red; }'; def content; p 'hello!'; end; end")

        file 'views/foo/bar/baz.pcss', %{
          div { color: blue; }
        }
      }
    end

    it "should be able to aggregate the CSS correctly still" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/foo/bar/baz.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/foo/bar/baz.pcss' do
          expect_wrapped_rule :div, 'color: blue'
        end
      end)
    end

    it "should apply the correct autogenerated class to the widget" do
      doc = render_file_asset('views/foo/bar/baz')
      expect(classes_from(doc, 'p')).to eq([ expected_file_asset('views/foo/bar/baz.rb').parcels_wrapping_class ])
    end
  end
end
