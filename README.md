# HubspotDataSync

Hi there, this is the reference project for the [video link here] video.

Always down for feedback about it. It's probably not the best that it could be, but for any learner, I want to have the project available here for you.

Happy coding!

## Description
This project shows an example of how to use Oban to build an API scaper (is that right?) where the program will utilize Oban to paginate through records on Hubspot and store them into a local PostgreSQL instance.

This thing is using Hammer to rate limit itself and a number of tests.

To be able to utilize it, you would need to set up PostgreSQL using the provided docker compose and get a HubSpot API key. It'll need to be set as an environment variable on your system as `HUBSPOT_TOKEN`
