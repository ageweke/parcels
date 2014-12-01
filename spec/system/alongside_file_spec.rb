describe "Parcels alongside files", :type => :system do
  context "with a very simple alongside file" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget('views/my_widget') { }
        file   'views/my_widget.css', %{
          p { color: red; }
        }
      }
    end

    it "should apply the correct autogenerated class to the widget" do
      doc = render_file_asset('views/my_widget')
      expect(classes_from(doc, 'p')).to eq([ expected_file_asset('views/my_widget.rb').parcels_wrapping_class ])
    end

    it "should aggregate the contents of that file" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.css' do
          expect_wrapped_rule :p, 'color: red'
        end
      end)
    end
  end

  context "with a widget ending in .rb and an alongside file ending in .html.css" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget('views/my_widget') { }
        file   'views/my_widget.html.css', %{
          p { color: red; }
        }
      }
    end

    it "should not aggregate that alongside file" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset_must_not_be_present 'views/my_widget.html.css'
      end)
    end
  end

  context "with a widget ending in .html.rb and an alongside file ending in .css" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget('views/my_widget.html') { }
        file   'views/my_widget.css', %{
          p { color: red; }
        }
      }
    end

    it "should not aggregate that alongside file" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset_must_not_be_present 'views/my_widget.css'
      end)
    end
  end

  context "with a widget ending in .html.rb, and an alongside file ending in .html.css" do
    before :each do
      files {
        file 'assets/basic.css', %{
          //= require_parcels
        }

        widget('views/my_widget.html') { }
        file   'views/my_widget.html.css', %{
          p { color: red; }
        }
      }
    end

    it "should apply the correct autogenerated class to the widget" do
      doc = render_file_asset('views/my_widget.html')
      expect(classes_from(doc, 'p')).to eq([ expected_file_asset('views/my_widget.rb').parcels_wrapping_class ])
    end

    it "should aggregate the contents of that file" do
      compiled_sprockets_asset('basic').should_match(file_assets do
        asset 'views/my_widget.html.css' do
          expect_wrapped_rule :p, 'color: red'
        end
      end)
    end
  end

  it "should combine an alongside file and inline CSS just fine" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      widget 'views/my_widget' do
        css %{
          p { color: green; }
        }
      end

      file 'views/my_widget.css', %{
        div { color: blue; }
      }
    }

    compiled_sprockets_asset('basic').should_match(file_assets do
      asset 'views/my_widget.css' do
        expect_wrapped_rule :div, 'color: blue'
      end

      asset 'views/my_widget.rb' do
        expect_wrapped_rule :p, 'color: green'
      end
    end)
  end

  it "should not allow you to pick up the alongside file with a direct 'require'" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      file 'assets/one.css', %{
        //= require 'views/my_widget.css'
      }

      widget('views/my_widget') { }
      file   'views/my_widget.css', %{
        p { color: red; }
      }
    }

    expect { compiled_sprockets_asset('one').source }.to raise_error(::Sprockets::FileNotFound, %r{views/my_widget\.css}i)
  end

  it "should allow you to pick up the alongside file with a 'require' using '_parcels/', and it should not be wrapped" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      file 'assets/one.css', %{
        //= require '_parcels/my_widget.css'
      }

      widget('views/my_widget') { }
      file   'views/my_widget.css', %{
        p { color: red; }
      }
    }

    compiled_sprockets_asset('one').should_match(file_assets do
      asset :head do
        expect_rule :p, 'color: red'
      end
    end)
  end

  it "should not pick up alongside files if there is no corresponding widget class" do
    files {
      file 'assets/basic.css', %{
        //= require_parcels
      }

      file   'views/my_widget.css', %{
        p { color: red; }
      }

      file   'views/another_widget.html.css', %{
        div { color: green; }
      }
    }

    compiled_sprockets_asset('one').should_match(file_assets do
      asset_must_not_be_present 'views/my_widget.css'
      asset_must_not_be_present 'views/another_widget.css'
    end)
  end
end
