# Last Active User ETL upsert method

Description: 
I have learn two ways to proceed the upsert method (insert + update) with last_active_user metric through python and SQL. It serves with different purpose depend on the destination source. For example, we want to transfers the executed result from last_active_user to db. Through python, we can use temp_table to extract the latest active and insert it into the table using SQL (INSERT INTO DO UPDATE). 


## Process

![Logic flowchart](flowchart.png)




Context

This is data dealing with mobile app usage of the customers, where an app has some personal information and online active timing of the customers. There are a lot of customers on this online platform. Whenever they login in-app and view anything, the app server gets pings from their mobile phone indicating that they are using the app. We have been provided with 3 weeks of training data and 1 week of test data. Training data contains id, gender, age, number of kids the customer has a and all the pings that have been received (during the training data period).

Our interest lies in predicting how many hours the customer will be online / using our app on a given day. So the test data contains customer id, and date (during the test data period). The test data also contains the actual online hours, which is what your model should predict.

We will be looking at Root Mean Squared Error or RMSE for short (lower the better) to see how good your model is.


