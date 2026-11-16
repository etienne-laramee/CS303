# Step 5: Reflections

## Design changes

At first, both treatment and price had a reference to the table visit, but since each treatment depends on a visit already, I found it less redundant to only have price reference treatment, and by joining tables, we can still find out which visit the price describes. That is one column and FK less in the schema and makes it a tiny bit more efficient.

## Debugging: What didn't work at first?

When working on step 2 to insert values in tables, I quickly figured my operations were not in the correct order, where I was trying to store patientOwner associations to owners that hadn't been inserted yet. So I re-arranged the operations so nothing that doesn't exist yet is being referenced to and it worked.

## Lessons learned

I already had a vague understanding of trigger, but this assignment helped be understand them much better.

At first I knew a trigger was a piece of code that executes after an event, but implmenting it taught me that we must first define a function, similar to a stored procedure, but instead of calling it ourselves with CALL \<function name\>, we configure it to be automatically called before, after or instead of an operation. What I found particularly interesting is the NEW keyword inside the function definition, which refers to the either pending or previously executed query entry, which we can use according to our needs.

## AI usage disclosure

ChatGPT has been used as a research tool alongside Google and the PostgreSQL docs. It has also been used to help generate some of the sample data, as permitted by the assignment instructions. Finally, it has been used as a help for debugging in a limited way only when no evident solution was found after manual analysis.
