# SSI Election Code

This code takes in the ballots cast in the SSI election and gives the winner.

## Installing
You will need ruby. This was written and tested with ruby 2.4.0 but other versions may work as well. 

After installing ruby and installing bundler (`gem install bundler`), you can install all dependecies with `bundle install`.

## Running code
Simply run
```bash
ruby scripts/main.rb BALLOT_FILE.tsv PAIRING_FILE.txt TIE_BREAKER_FILE.txt
```

For example
```bash
ruby scripts/main.rb spec/data/sample-ballots-1.tsv spec/data/sample-pairings-1.txt spec/data/sample-tie-breakers-1.txt
```

## Running tests
To run the tests, run `bundle exec rspec`. It will print out if the tests passed -- or if they failed, which ones did.

To run the tests with code coverage tools enabled, run `bundle exec deep-cover exec rspec`. This will output a summary of
 code coverage and generate a report in the coverage folder. It currently has 100% coverage except for a single line 
 (which simple passes command line arguments into an entry method)

## Licence 
MIT