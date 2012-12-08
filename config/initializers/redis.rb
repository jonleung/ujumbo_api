require 'redis'
require 'redis/objects'
require 'redis/hash_key'
require 'redis/list'
require 'redis/set'
require 'redis/sorted_set'

require 'redis/counter'
require 'redis/lock'
require 'redis/value'

Redis.current = Redis.new(:host => '127.0.0.1', :port => 6379)
$redis = Redis.current