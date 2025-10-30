
at_exit do
  if defined?(SimpleCov) && SimpleCov.running
    result = SimpleCov.result
    result.format!
    
    if result
      puts "\n" + "="*80
      puts "Code Coverage Summary"
      puts "="*80
      puts "Overall Coverage: #{result.covered_percent.round(2)}%"
      puts "Lines Covered: #{result.covered_lines}/#{result.total_lines}"
      
      puts "\nCoverage Report: coverage/index.html"
      puts "="*80 + "\n"
    end
  end
end

