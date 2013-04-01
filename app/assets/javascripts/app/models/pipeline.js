App.Pipeline = Ember.Resource.define({
  url: "/pipelines",
  schema: {
    id: Number,
    name: String,
    pipes: {
      
    }
  }
})