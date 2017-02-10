
#!/usr/bin/env ruby
require 'json'



file1 = File.read('trait_descriptors.json')
file2 = File.read('trait_scores.json')
trait_descriptors_hash = JSON.parse(file1)
trait_scores_hash = JSON.parse(file2)

=begin
trait_scores_hash.each do |key|
 for key in trait_scores_hash.key()
      print key ,trait_scores_hash[key]
    end
end
=end

#creates nested hash structure
out_hash = Hash.new
out_hash.default_proc = proc do |hash, key|
  hash[key] = Hash.new
end


trait_scores_hash.each_pair do |k,v|
	out_hash[k]["score_value"] = v["score_value"]
end

trait_scores_hash.each_pair do |k,v|
	out_hash[k]["trait_descriptor_id"] = v["trait_descriptors_hash"]
end


#And the same for the opposite.
#If the hashes are too big, and you want to remove instead of add, you should instead merge the two
#internal hashes and then apply the delete!("some_key_to_delete") (h.merge(other_h))
