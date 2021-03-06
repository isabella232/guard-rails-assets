require 'guard/compat/test/helper'
require 'guard/rails-assets'

require_relative '../support/shared_examples'

RSpec.describe Guard::RailsAssets do
  context 'with any runner' do
    let(:options) { { runner: :cli } }
    let(:runner) { double('runner') }
    subject { Guard::RailsAssets.new(options) }

    before do
      allow(Guard::RailsAssets::CliRunner).to receive(:new).and_return runner
    end

    describe '#start' do
      it_behaves_like 'guard command', command: :start,         run: true
    end

    describe '#reload' do
      it_behaves_like 'guard command', command: :reload,        run: false
    end

    describe '#run_all' do
      it_behaves_like 'guard command', command: :run_all,       run: false
    end

    describe '#run_on_change' do
      it_behaves_like 'guard command', command: :run_on_change, run: true
    end

    describe 'run options' do
      it 'should allow array of symbols' do
        guard = Guard::RailsAssets.new(run_on: [:start, :change])
        expect(guard.run_for?(:start)).to be_truthy
        expect(guard.run_for?(:reload)).to be_falsey
      end

      it 'should allow symbol' do
        guard = Guard::RailsAssets.new(run_on: :start)
        expect(guard.run_for?(:start)).to be_truthy
        expect(guard.run_for?(:reload)).to be_falsey
      end
    end

    describe 'notifications' do
      def stub_system_with(result)
        expect(runner).to receive(:compile_assets).and_return result
      end

      it 'should notify on success' do
        stub_system_with true
        expect(Guard::Compat::UI).to receive(:notify).with('Assets compiled')
        subject.compile_assets
      end

      it 'should notify on failure' do
        stub_system_with false
        expect(Guard::Compat::UI).to receive(:notify)
          .with('see the details in the terminal', title: "Can't compile assets", image: :failed)
        subject.compile_assets
      end
    end
  end # context with any runner

  describe 'picking a runner' do
    it 'should use Rails runner by default' do
      expect(Guard::RailsAssets.new.runner.class).to eq(::Guard::RailsAssets::RailsRunner)
    end

    it 'should use CLI runner' do
      expect(Guard::RailsAssets.new(runner: :cli).runner.class).to eq(::Guard::RailsAssets::CliRunner)
    end

    it 'should use RailsRunner' do
      expect(Guard::RailsAssets.new(runner: :rails).runner.class).to eq(::Guard::RailsAssets::RailsRunner)
    end
  end
end
