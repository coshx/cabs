yml_file = Rails.root.join('config', 'titles.yml')
TITLES = YAML::load(File.open(yml_file))
TITLES.each_with_index do |t, i|
  TITLES[i]["slug"] = t["title"].parameterize
end
