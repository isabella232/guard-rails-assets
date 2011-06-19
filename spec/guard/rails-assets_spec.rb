require 'spec_helper'
require 'guard/rails-assets'

describe Guard::RailsAssets do
  let(:options) { {} }
  subject { Guard::RailsAssets.new(['watchers'], options) }

  it 'should be able to create guard' do
    ::Guard::RailsAssets.new(['watchers'], {:options=>:here}).should_not be_nil
  end

  describe '#start' do
    it_behaves_like 'guard command', :command => :start,         :run => true
  end

  describe '#reload' do
    it_behaves_like 'guard command', :command => :reload,        :run => false
  end

  describe '#run_all' do
    it_behaves_like 'guard command', :command => :run_all,       :run => true
  end

  describe '#run_on_change' do
    it_behaves_like 'guard command', :command => :run_on_change, :run => true
  end


  describe 'asset compilation using CLI' do
    def stub_system_with result
      subject.should_receive(:system).with("bundle exec rake assets:clean assets:precompile").and_return result
    end

    it 'should notify on success' do
      stub_system_with true
      Guard::Notifier.should_receive(:notify).with('Assets compiled')
      subject.compile_assets
    end
    it 'should notify on failure' do
      stub_system_with false
      subject.should_not_receive(:`) # don't obtain tree
      Guard::Notifier.should_receive(:notify).with('see the details in the terminal', :title => "Can't compile assets", :image => :failed)
      subject.compile_assets
    end
  end
end
