# Custom auto number for Loan number field on Opportunity

### Loan number should follow pattern YY0000, YY0001, YY0002,.....
### Used custom setting to store a record with number field set to zero
### Apex trigger on opportunity insert - fetches the custom setting value and assignes it to the loan number field, and then increments the number in custom setting and updates it, so that this number is used when next opportunity is created
### The number in custom setting is reset at start of each year using a schedulable batch class