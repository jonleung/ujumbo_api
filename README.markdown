## Triggers

Any class or module can be triggerable by `include Trigger` and adding a method `def trigger` that is to be triggered

```ruby
class AnyClass
  include Trigger

  def trigger(hash)
    #what code you want executed
  end

  ...
end
```

By including the Trigger module, it defines a method in the class with a signature

```ruby
def set_trigger(trigger, params)
```

### Example Usage

```ruby
class Pipeline
  #...
  include Trigger

  def trigger(hash)
    self.pipes.each do |pipe|
      pipe.flow(params)
    end
  end

end
#...
```

And so this lets us do

```ruby
  # Creating a new Pipeline
  pipeline = Pipeline.new
  pipeline.pipes << ...
  ...
  pipeline.save

  pipeline.set_trigger("database:user:create", {type: "student"})
```

and then to actually call this

```ruby
class User < Ujumbo::UjumboRecord::base

  after_create :after_create_hook
  
  def after_create_hook
    ...
    Trigger.trigger("database:user:create", self.attributes)
    ...
  end
  ...
end
```