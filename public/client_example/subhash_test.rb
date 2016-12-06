
#!/usr/bin/env ruby
require 'json'
# this might be an important gem to install to be able to run some functions
# gem 'active_support'
#require 'active_support/core_ext/hash/slice'
# but am not going to use it as this woulr require the user of the script to have these gems in place, too.


file1 = File.read('trait_descriptors.json')
file2 = File.read('trait_scores.json')
trait_descriptors_hash = JSON.parse(file1)
trait_scores_hash = JSON.parse(file2)

length =trait_scores_hash.length
puts length


#works on one single entry, and returnd only the key score_value
puts trait_scores_hash[0].select{|key,value| key=="score_value"}

 #becasue the below  somehow doesn't work:
#puts trait_scores_hash.each.select { |key,value| key=="score_value" }

# I am trying to loop:
$i = 0
while $i <= trait_scores_hash.length do
 puts  trait_scores_hash[$i].select{|key,value| key==("score_value"  "value_type")}
 $i +=1
 end
# But I am unable to use "and" or &&  or a list of key values, and it only works if I have one key.....




#puts trait_scores_hash.delete_if { |key| !key.to_s.match(/^choice\d+/) }


#for rails only?
#puts trait_scores_hash[0].slice(:score_value, :value_type)
#puts trait_scores_hash[0].extract(:score_value, :value_type)

#puts trait_scores_hash[0].select{ |k, v| k == "score_value" && k == "value_type" }

puts trait_descriptors_hash[0]["descriptor_label"]


h = { "d" => 100, "a" => 200, "v" => 300, "e" => 400 }
puts h.select {|k,v| k == "a" && "v"}

=begin
puts trait_scores_hash[0]["score_value"]

trait_scores_hash.find_all { |key, val| key == "score_value" }
trait_scores_hash.length


# puts selected_keys


=begin

def filter1(hsh, *keys)
  hsh.reject { |k, _| keys.include? k }
end

#to remove default metadata
default = {"entered_by_whom","date_entered","data_provenance","data_owned_by"}


puts filter1(trait_scores_hash[0],default)

trait_scores_hash.each do |key|
  for key in trait_scores_hash.key()
      print key ,trait_scores_hash[key]
    end
end

trait_scores_hash = Hash.new {|h,k| h[k] = Hash.new}
trait_scores_hash[:trait_descriptor_id][:trait_descriptor_id] = trait_descriptors_hash


# File activesupport/lib/active_support/core_ext/hash/deep_merge.rb, line 21
  def deep_merge!(other_hash, &block)
    other_hash.each_pair do |current_key, other_value|
      this_value = self[current_key]

      self[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
        this_value.deep_merge(other_value, &block)
      else
        if block_given? && key?(current_key)
          block.call(current_key, this_value, other_value)
        else
          other_value
        end
      end
    end

    self
  end

  final= trait_descriptors_hash.deep_merge!(trait_scores_hash)


=end
