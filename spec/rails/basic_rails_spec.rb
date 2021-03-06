describe "Parcels Rails basic support", :type => :rails do
  uses_rails_with_template :basic_rails_spec

  it "should at least have a working Rails server" do
    expect_match("simple_css", /hello, world/)
  end

  it "should wrap a simple widget in a class" do
    expected_class = expected_rails_asset('views/basic_rails_spec/simple_css.rb').parcels_wrapping_class
    expect_match("simple_css", /<p class="#{Regexp.escape(expected_class)}">hello, world<\/p>/)
  end

  it "should contain the CSS in application.css due to the 'require_parcels' directive" do
    asset = compiled_rails_asset('application.css')

    asset.should_match(rails_assets do
      asset 'views/basic_rails_spec/simple_css.rb' do
        expect_wrapped_rule nil, 'color: green'
      end
      allow_additional_assets!
    end)
  end

  it "should support both inline and alongside CSS on a .rb widget" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/basic_rails_spec/alongside_and_inline.rb' do
        expect_wrapped_rule :p, 'color: green'
      end

      asset 'views/basic_rails_spec/alongside_and_inline.pcss' do
        expect_wrapped_rule :div, 'color: blue'
      end

      allow_additional_assets!
    end)
  end

  it "should support both inline and alongside CSS on a .html.rb widget" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/basic_rails_spec/alongside_and_inline_html.html.rb' do
        expect_wrapped_rule :p, 'color: yellow'
      end

      asset 'views/basic_rails_spec/alongside_and_inline_html.html.pcss' do
        expect_wrapped_rule :div, 'color: purple'
      end

      allow_additional_assets!
    end)
  end

  it "should allow precompiling assets with 'rake'" do
    rails_server.run_command_in_rails_root!("rake assets:precompile --trace")

    asset = precompiled_rails_asset('application.css')
    asset.should_match(rails_assets do
      asset 'views/basic_rails_spec/simple_css.rb' do
        expect_wrapped_rule nil, 'color: green'
      end
      allow_additional_assets!
    end)
  end

  it "should not pick up alongside files if there is no corresponding widget class" do
    compiled_rails_asset('application.css') do
      asset_must_not_be_present('views/basic_rails_spec/no_corresponding_widget.pcss')
      allow_additional_assets!
    end
  end

  it "should allow using ERb in inline CSS if desired" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/basic_rails_spec/inline_erb.rb' do
        expect_wrapped_rule :p, 'background-image: url("foo-21")'
      end
      allow_additional_assets!
    end)
  end

  it "should allow using ERb in alongside CSS if desired" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/basic_rails_spec/alongside_erb.pcss' do
        expect_wrapped_rule :p, 'background-image: url("foo-21")'
      end
      allow_additional_assets!
    end)
  end

  it "should allow using other asset-pipeline engines (extensions) if desired" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/basic_rails_spec/multiple_engines.rb' do
        expect_wrapped_rule :p, 'background-image: url("21")'
      end

      asset 'views/basic_rails_spec/multiple_engines.pcss' do
        expect_wrapped_rule :div, 'background-image: url("21")'
      end

      allow_additional_assets!
    end)
  end

  it "should allow putting a .rb file in views/ that is just a module (~ helpers)" do
    compiled_rails_asset('application.css').should_match(rails_assets do
      asset 'views/basic_rails_spec/helpers_module_test.rb' do
        expect_wrapped_rule :p, 'color: green'
      end
      allow_additional_assets!
    end)

    expect_match("helpers_module_test", /and it is this is my_helper\! tada\!/)
  end
end
