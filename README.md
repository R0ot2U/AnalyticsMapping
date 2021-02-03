# Analytics Mapping

## Current Functionality
- Pull all DataflowJobs into an SObject 
  - Fields included
    - Dataflow (Lookup to Dataflow SObject)
    - Duration
    - Dataflow Instance Id (**prefix**: 03C)
    - Executed DateTime
    - Job Type 
      - (DataSync, FileUpload, Internal, Recipe, RecipeV3, Report, Restore, User)
    - Label (Flow Name) 
    - Message (Warning/Info/Error messages)
    - Nodes URL
    - Progress
    - Start DateTime
    - Status
- Create Dataflow records for all Dataflows and Recipes
  - Fields included
    - Average Duration (Minutes) *populated by trigger on dataflowJob inserts*
    - Dataflow Id (**prefix**: 02K & 05v)
    - Dataflow Name (Flow Name)
    - Max Duration (Seconds)
    - Min Duration (Seconds)
    - Next Run Date
    - Schedule *cronExpression*
    - Type 
        - Dataflow
        - Recipe
        - RecipeV3
- Estimate future schedule visually
    ![image of Analytics Map](https://github.com/R0ot2U/AnalyticsMapping/blob/master/images/Map%20Demo%201.png?raw=true)
- View historical runs visually

## In Progress
- Schedule reading of Dataflows as this is in JSON format currently
- CronExpression creator/validator
- CronExpression estimator : replacement for external API
- Edit Schedules in the Map view

## Roadmap
- Orchestration