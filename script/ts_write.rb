#!/usr/local/bin/ruby

$LOAD_PATH << File.join(File.dirname(__FILE__),'../lib')
require 'deep_test/server'
require 'deep_test/tuple_space_factory'

tuple_space = DeepTest::TupleSpaceFactory.tuple_space
tuple_space.write ARGV