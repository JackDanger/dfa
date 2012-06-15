
class DFA
  require 'set'

  attr_accessor :initial

  def initialize(alphabet)
    raise "The alphabet must be a Set" unless alphabet.is_a?(Set)
    raise "The alphabet must not be empty" if alphabet.empty?
    @alphabet = alphabet
  end

  def accepts?(string)
    string.split('').inject(initial) do |state, character|
      state.next_for(character)
    end.accepting?
  end

  class State

    def initialize
      @map = {}
    end

    def accepting!
      @accepting = true
    end

    def accepting?
      @accepting
    end

    def on(char, walk)
      raise "#{char} is already defined" if @map.has_key?(char)
      @map[char] = walk
    end

    def next_for(char)
      @map[char] || self
    end
  end
end












describe DFA do
  let(:alphabet) { Set.new(['a', 'b', 'c', 'd', 'e']) }
  let(:dfa) { DFA.new alphabet }
  describe '#initialize' do
    subject { dfa }
    context "with a non-set alphabet provided" do
      let(:alphabet) { ['a', 'b', 'b'] }
      it "raises an error" do
        expect { subject }.to raise_error
      end
    end
    context "with an empty alphabet provided" do
      let(:alphabet) { Set.new }
      it "raises an error" do
        expect { subject }.to raise_error
      end
    end
  end

  describe DFA::State do
    let(:first)  { DFA::State.new }
    let(:second) { DFA::State.new }

    describe '#on' do
      subject {
        first.on 'd', second
        first.accepting!
        first
      }
      it "stores each next state" do
        subject.next_for('d').should == second
      end
      it "stores whether this state is accepting" do
        subject.should be_accepting
      end
      context "when overdefining a transition" do
        it "raises an error" do
          expect {
            first.on 'c', first
            first.on 'c', second
          }.to raise_error
        end
      end
    end

    describe '#next_for' do
      before {
        first.on 'd', second
        first.accepting!
      }
      subject { first.next_for character }

      let(:character) { 'd' }
      it { should == second }

      context "with a character not defined on the state" do
        let(:character) { 'a' }
        it "defaults to same state" do
          subject.should == first
        end
      end
    end
  end
end

describe 'integration' do
  it "complets a DFA acceptance" do
    dfa = DFA.new(Set.new(['a', 'b', 'c']))
    first  = DFA::State.new
    second = DFA::State.new
    third  = DFA::State.new
    first.on 'a', first
    first.on 'b', second
    first.on 'c', third
    second.on 'a', second
    second.on 'b', third
    second.on 'c', first
    third.on 'a', third
    third.on 'b', first
    third.on 'c', second
    third.accepting!

    dfa.initial = first

    dfa.accepts?('aaaaaabbaaaacb').should be_true
    dfa.accepts?('aaa').should be_false
    dfa.accepts?('abbb').should be_false
    dfa.accepts?('bbb').should be_false
    dfa.accepts?('bbbbbbbbbbbbb').should be_false
    dfa.accepts?('ccc').should be_false
    dfa.accepts?('c').should be_true
  end
end
