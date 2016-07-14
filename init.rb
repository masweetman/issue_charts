Redmine::Plugin.register :issue_charts do

  name 'Issue Charts plugin'
  author 'Mike Sweetman'
  description 'Adds charts and graphs for project issues.'
  version '0.0.1'
  url 'https://github.com/masweetman/issue_charts'
  author_url 'https://github.com/masweetman/'

  project_module :charts do
    permission :view_charts, :charts => [:index]
    permission :create_charts, :charts => [:new]
    permission :edit_charts, :charts => [:edit, :update]
  end
  
  menu :project_menu, :charts, { :controller => 'charts', :action => 'index' }, :caption => 'Charts', :after => :issues, :param => :project_id

end
