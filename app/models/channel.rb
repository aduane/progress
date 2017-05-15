# frozen_string_literal: true

require 'securerandom'

# this is a grouping of tasks that can be subscribed to
class Channel
  attr_accessor :api_key, :name

  def self.create
    new_channel = new
    self.name = generate_name while redis.get(new_channel.redis_key).present?
    redis.set(new_channel.redis_key, new_channel.api_key)
    new_channel
  end

  def initialize
    self.api_key = SecureRandom.uuid
    self.name = generate_name
  end

  def redis_key
    "channel:#{name}"
  end

  def as_json(*)
    { api_key: api_key, channel_name: name }
  end

  private_class_method
  def self.redis
    @redis ||= Redis.new
  end

  private

  def generate_name
    [adjectives.sample, nouns.sample, random_number].join('-')
  end

  def adjectives # rubocop:disable Metrics/MethodLength
    %w[absolute adorable adventurous academic acceptable acclaimed accomplished
       accurate admirable admired adorable adored advanced affectionate
       altruistic amazing ambitious amused amusing angelic animated antique
       artistic attentive authentic average beautiful beloved beneficial brave
       bright brilliant bronze bubbly busy calm candid carefree
       careful careless caring charming cheerful cheery classic
       clever colorful comfortable compassionate composed considerate
       content coordinated courageous courteous crafty cuddly cultured
       dapper daring darling dazzling decent delightful dependable determined
       diligent eager earnest educated elegant enchanted enchanting esteemed
       ethical euphoric excellent exemplary fabulous fantastic favorable
       favorite fearless flawless friendly frightened generous
       gentle genuine giddy gifted glamorous gleaming gleeful
       glittering glorious graceful gracious grateful happy
       harmless helpful honest honorable honored hopeful hospitable
       imaginary imaginative impeccable improbable incredible intelligent
       interesting jovial joyful joyous jubilant kind kindhearted
       knowledgeable kooky likable lively lovable lovely loving loyal
       magnificent majestic marvelous mellow melodic memorable merry modern
       mysterious nice nifty nimble notable noteworthy novel offbeat optimistic
       overjoyed peaceful pleasant polite positive precious prestigious pretty
       precious pristine prudent quaint quirky radiant reasonable reliable
       remarkable respectful responsible scholarly scientific sentimental serene
       shimmering shiny smart sparkling spectacular splendid stylish supportive
       sweet sympathetic terrific thankful thoughtful thrifty trustworthy
       truthful upbeat useful valuable vibrant vigilant virtual vivacious vivid
       warmhearted whimsical wonderful worthy]
  end

  def nouns # rubocop:disable Metrics/MethodLength
    %w[alligator antelope badger bear beetle bird bison camel cardinal cat
       caterpillar chameleon cheetah cougar crane dog dolphin donkey
       dragonfly eagle egret elephant emu fish flamingo fox frog giraffe
       goat grasshopper hippopotamus horse iguana impala jaguar kangaroo koala
       kookaburra lemur leopard lion lizard macaw marmot monkey ocelot octopus
       orca owl panda pelican pig pony puffin raccoon raven rhinoceros sheep
       skink snake squirrel stork sunfish swan tiger toad tortoise turkey
       wallaby walrus warthog wildebeest wolf zebra fountain pool pond cascade
       waterfall stream dune glacier cove wood forest valley canyon whirlpool
       hill mountain island coast fjord peninsula marsh shore cape cliff cave
       shoal creek summit cay bluff ridge gorge]
  end

  def random_number
    SecureRandom.random_number(9999)
  end
end
