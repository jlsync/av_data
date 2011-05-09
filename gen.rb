#!/usr/bin/env ruby


input = "HouseDopByDivisionDownload-15508.csv"
lines = open(input).readlines.map{|l| l.chomp.split(",")}
lines.shift
lines.shift

divisions = lines.map{|l| l[2]}.uniq

divisions.each do |division_name|

  division_lines = lines.select{|l| l[2] == division_name }

  votes = []
  candidates = {}
  eliminated = []

  division_lines.select{|l| l[3].to_i == 0 and l[12] == "Preference Count"}.each do |l|
    candidates[l[4]] =  l[7].gsub(/\s+/,"_") + "_" + l[6].gsub(/\s+/,"_")  + "__" + l[9].gsub(/\s+/,"_") 
  end

  this_round = 0 
  first_round = division_lines.select{|l| l[3].to_i == this_round}


  first_prefs = first_round.select{|l| l[12] == "Preference Count"}.each do |l|
    l[13].to_i.times do 
      votes << [ l[4] ]
    end
  end

  this_round += 1 

  while division_lines.select{|l| l[3].to_i == this_round}.size > 0
    elim = division_lines.select{|l| l[3].to_i == this_round and l[12] == "Transfer Count" and l[13].to_i < 0}[0][4]
    elim_votes = votes.select{|v| v.reject{|c| eliminated.include? c}.first == elim }
    remaining_positions = division_lines.select{|l| l[3].to_i == this_round and l[12] == "Preference Count" and l[13].to_i > 0}.map{|l| l[4]}
    i = 0
    transfers = division_lines.select{|l| l[3].to_i == this_round and l[12] == "Transfer Count"and remaining_positions.include?(l[4]) }
    transfers.each do |t|
      t[13].to_i.times do 
        # pad out vote with elimitaed candiates here.
        if eliminated.size > 0 and rand > 0.4 
          try = eliminated[rand eliminated.size]
          if try and !elim_votes[i].include?(try)
            elim_votes[i] << try
          end
        end
        
        elim_votes[i] << t[4]
        i += 1
      end
    end
    eliminated << elim
    this_round += 1 
  end


  votes = votes.map do |vote|
    vote += candidates.keys.sort_by{|k| rand}.map{|k| k.to_s}
    vote.uniq
  end


  f = File.open("#{division_name}.txt", "w")
  votes.sort_by{|v| rand}.each do |vote|
    f.write vote.map{|k| candidates[k]}.join(", ") + "\n"
  end
  f.close

end
