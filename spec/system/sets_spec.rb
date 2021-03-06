describe "Parcels sets", :type => :system do
  context "with widgets in various sets" do
    before :each do
      files {
        file 'assets/one.css', %{
          //= require_parcels
        }

        file 'assets/two.css', %{
          //= require_parcels aaa
        }

        file 'assets/three.css', %{
          //= require_parcels bbb
        }

        file 'assets/four.css', %{
          //= require_parcels aaa bbb
        }

        file 'assets/five.css', %{
          //= require_parcels  aaa,   bbb
        }

        widget 'views/parent_widget' do
          css %{
            p { color: red; }
          }

          sets :aaa
        end

        widget 'views/widget_one', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{div { color: green; }}
        end

        file 'views/widget_one.pcss', %{
          div.a { color: green; }
        }

        widget 'views/widget_two', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{span { color: blue; }}
          sets :bbb
        end

        file 'views/widget_two.pcss', %{
          span.a { color: blue; }
        }

        widget 'views/widget_three', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{em { color: yellow; }}
          sets :aaa, :bbb
        end

        file 'views/widget_three.pcss', %{
          em.a { color: yellow; }
        }

        widget 'views/widget_four', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{strong { color: cyan; }}
          sets nil
        end

        file 'views/widget_four.pcss', %{
          strong.a { color: cyan; }
        }

        widget 'views/widget_five', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{h1 { color: magenta; }}
          sets :aaa
        end

        file 'views/widget_five.pcss', %{
          h1.a { color: magenta; }
        }

        widget 'views/widget_six', :superclass => 'Views::ParentWidget' do
          requires %{views/parent_widget}
          css %{h2 { color: black; }}
          sets_block %{do |klass, filename|
  if klass.name =~ /seven/i
    [ :aaa, :bbb ]
  elsif filename =~ /widget_eight/i
    :aaa
  else
    :bbb
  end
end
}
        end

        file 'views/widget_six.pcss', %{
          h2.a { color: black; }
        }

        widget 'views/widget_seven', :superclass => 'Views::WidgetSix' do
          requires %{views/widget_six}
          css %{h3 { color: white; }}
        end

        file 'views/widget_seven.pcss', %{
          h3.a { color: white; }
        }

        widget 'views/widget_eight', :superclass => 'Views::WidgetSix' do
          requires %{views/widget_six}
          css %{h4 { color: red; }}
        end

        file 'views/widget_eight.pcss', %{
          h4.a { color: red; }
        }
      }
    end

    it "should put everything in if you don't specify any sets" do
      compiled_sprockets_asset('one').should_match(file_assets do
        asset 'views/parent_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/widget_one.rb' do
          expect_wrapped_rule :div, 'color: green'
        end

        asset 'views/widget_one.pcss' do
          expect_wrapped_rule :'div.a', 'color: green'
        end

        asset 'views/widget_two.rb' do
          expect_wrapped_rule :span, 'color: blue'
        end

        asset 'views/widget_two.pcss' do
          expect_wrapped_rule :'span.a', 'color: blue'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.pcss' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_four.rb' do
          expect_wrapped_rule :strong, 'color: cyan'
        end

        asset 'views/widget_four.pcss' do
          expect_wrapped_rule :'strong.a', 'color: cyan'
        end

        asset 'views/widget_five.rb' do
          expect_wrapped_rule :h1, 'color: magenta'
        end

        asset 'views/widget_five.pcss' do
          expect_wrapped_rule :'h1.a', 'color: magenta'
        end

        asset 'views/widget_six.rb' do
          expect_wrapped_rule :h2, 'color: black'
        end

        asset 'views/widget_six.pcss' do
          expect_wrapped_rule :'h2.a', 'color: black'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.pcss' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end

        asset 'views/widget_eight.rb' do
          expect_wrapped_rule :h4, 'color: red'
        end

        asset 'views/widget_eight.pcss' do
          expect_wrapped_rule :'h4.a', 'color: red'
        end
      end)
    end

    it "should put in just that one set if that's what you ask for" do
      compiled_sprockets_asset('two').should_match(file_assets do
        asset 'views/parent_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/widget_one.rb' do
          expect_wrapped_rule :div, 'color: green'
        end

        asset 'views/widget_one.pcss' do
          expect_wrapped_rule :'div.a', 'color: green'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.pcss' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_five.rb' do
          expect_wrapped_rule :h1, 'color: magenta'
        end

        asset 'views/widget_five.pcss' do
          expect_wrapped_rule :'h1.a', 'color: magenta'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.pcss' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end

        asset 'views/widget_eight.rb' do
          expect_wrapped_rule :h4, 'color: red'
        end

        asset 'views/widget_eight.pcss' do
          expect_wrapped_rule :'h4.a', 'color: red'
        end
      end)
    end

    it "should put in just the other set if that's what you ask for" do
      compiled_sprockets_asset('three').should_match(file_assets do
        asset 'views/widget_two.rb' do
          expect_wrapped_rule :span, 'color: blue'
        end

        asset 'views/widget_two.pcss' do
          expect_wrapped_rule :'span.a', 'color: blue'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.pcss' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_six.rb' do
          expect_wrapped_rule :h2, 'color: black'
        end

        asset 'views/widget_six.pcss' do
          expect_wrapped_rule :'h2.a', 'color: black'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.pcss' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end
      end)
    end

    it "should let you separate set names with a comma, and still work fine" do
      compiled_sprockets_asset('five').should_match(file_assets do
        asset 'views/parent_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/widget_one.rb' do
          expect_wrapped_rule :div, 'color: green'
        end

        asset 'views/widget_one.pcss' do
          expect_wrapped_rule :'div.a', 'color: green'
        end

        asset 'views/widget_two.rb' do
          expect_wrapped_rule :span, 'color: blue'
        end

        asset 'views/widget_two.pcss' do
          expect_wrapped_rule :'span.a', 'color: blue'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.pcss' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_five.rb' do
          expect_wrapped_rule :h1, 'color: magenta'
        end

        asset 'views/widget_five.pcss' do
          expect_wrapped_rule :'h1.a', 'color: magenta'
        end

        asset 'views/widget_six.rb' do
          expect_wrapped_rule :h2, 'color: black'
        end

        asset 'views/widget_six.pcss' do
          expect_wrapped_rule :'h2.a', 'color: black'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.pcss' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end

        asset 'views/widget_eight.rb' do
          expect_wrapped_rule :h4, 'color: red'
        end

        asset 'views/widget_eight.pcss' do
          expect_wrapped_rule :'h4.a', 'color: red'
        end
      end)
    end

    it "should put in both sets if you ask, but not things with no sets at all" do
      compiled_sprockets_asset('four').should_match(file_assets do
        asset 'views/parent_widget.rb' do
          expect_wrapped_rule :p, 'color: red'
        end

        asset 'views/widget_one.rb' do
          expect_wrapped_rule :div, 'color: green'
        end

        asset 'views/widget_one.pcss' do
          expect_wrapped_rule :'div.a', 'color: green'
        end

        asset 'views/widget_two.rb' do
          expect_wrapped_rule :span, 'color: blue'
        end

        asset 'views/widget_two.pcss' do
          expect_wrapped_rule :'span.a', 'color: blue'
        end

        asset 'views/widget_three.rb' do
          expect_wrapped_rule :em, 'color: yellow'
        end

        asset 'views/widget_three.pcss' do
          expect_wrapped_rule :'em.a', 'color: yellow'
        end

        asset 'views/widget_five.rb' do
          expect_wrapped_rule :h1, 'color: magenta'
        end

        asset 'views/widget_five.pcss' do
          expect_wrapped_rule :'h1.a', 'color: magenta'
        end

        asset 'views/widget_six.rb' do
          expect_wrapped_rule :h2, 'color: black'
        end

        asset 'views/widget_six.pcss' do
          expect_wrapped_rule :'h2.a', 'color: black'
        end

        asset 'views/widget_seven.rb' do
          expect_wrapped_rule :h3, 'color: white'
        end

        asset 'views/widget_seven.pcss' do
          expect_wrapped_rule :'h3.a', 'color: white'
        end

        asset 'views/widget_eight.rb' do
          expect_wrapped_rule :h4, 'color: red'
        end

        asset 'views/widget_eight.pcss' do
          expect_wrapped_rule :'h4.a', 'color: red'
        end
      end)
    end
  end
end
