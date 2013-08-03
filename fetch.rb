require 'json'
require 'net/http'
require 'beeminder'
def fetchExercise(name)
  response=Net::HTTP.get_response("markfit.herokuapp.com", "/user/mwotton/activity/#{name}")

  j = JSON.parse(response.body) 
  bytime={}; 

  j.each do |x| 
    a=x['actions']; 
    a.each do |b|
      time = DateTime.parse(b['actiontime'])
      bytime[time] ||= []
      bytime[time] << [b['effort0'],b['effort1']] 
    end
  end
  bytime
end

results = fetchExercise("Barbell%20Squat")

print results


token = "jdai1FyoYT46ohZbKxPp"

datapoints = results.map do |time, sets| 
  highest = sets.map(&:first).max
  # goal.add
  Beeminder::Datapoint.new(:value => highest, :timestamp => time)
end

volume = results.map do |time, sets|
  total = sets.map {|[weight, reps]| Float(weight) * Float(reps)}.sum
  Beeminder::Datapoint.new(:value => total, :timestamp => time)
end


print datapoints

bee = Beeminder::User.new token
goal = bee.goal "barbell-squat-max" # "Barbell%20Squat%20Max"

goal.add(datapoints)
goal.update
