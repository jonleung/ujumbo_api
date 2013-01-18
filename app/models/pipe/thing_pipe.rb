class ThingPipe < Pipe
  include Mongoid::Document
  self.mass_assignment_sanitizer = :strict


end