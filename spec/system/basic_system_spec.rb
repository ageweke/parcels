describe "Parcels basic operations", :type => :system do
  context "with a simple widget" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/my_widget' do
          css %{
            p { color: red; }
          }
        end

        file 'views/my_widget.pcss', %{
          div { color: blue; }
        }
      }
    end

    it "should aggregate the CSS from a simple widget properly" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/my_widget.pcss' do
          expect_wrapped_rule :div, 'color: blue'
        end
      end)
    end

    it "should apply the correct autogenerated class to the widget" do
      doc = render_file_asset('views/my_widget')
      expect(classes_from(doc, 'p')).to eq([ expected_file_asset('views/my_widget.rb').parcels_wrapping_class ])
    end
  end

  context "with a widget ending in .html.rb" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget 'views/my_widget.html' do
          css %{
            p { color: red; }
          }
        end

        file 'views/my_widget.html.pcss', %{
          div { color: blue; }
        }
      }
    end

    it "should aggregate the CSS from a simple widget properly" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.html.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/my_widget.html.pcss' do
          expect_wrapped_rule :div, 'color: blue'
        end
      end)
    end

    it "should apply the correct autogenerated class to the widget" do
      doc = render_file_asset('views/my_widget.html')
      expect(classes_from(doc, 'p')).to eq([ expected_file_asset('views/my_widget.html.rb').parcels_wrapping_class ])
    end
  end
end
