# frozen_string_literal: true
require 'rails_helper'

describe ParserVersion do
  let(:parser) { Parser.new(name: 'Europeana', id: '123', data_type: 'Record', source: source) }
  let(:parser_version) { ParserVersion.new(parser_id: '123') }
  let(:job) { mock_model(HarvestJob).as_null_object }
  let(:source) { Source.new(source_id: 'source_name') }

  describe '#last_harvested_at' do
    let!(:time) { Time.now }
    let!(:job1) { create(:harvest_job, start_time: time - 1.day, parser_id: '12', status: 'finished') }
    let!(:job2) { create(:harvest_job, start_time: time - 2.day, parser_id: '12', status: 'finished') }

    it 'returns the last date a harvest job was run' do
      Timecop.freeze(time) do
        parser = Parser.new(id: '12', name: 'Europeana')
        expect(parser.last_harvested_at.to_i).to eq (time - 1.day).to_i
      end
    end

    it 'returns nil when no job has been run' do
      parser = Parser.new(id: '123', name: 'Europeana')
      expect(parser.last_harvested_at).to be_nil
    end
  end

  describe '#harvest_jobs' do
    it 'finds all the harvest jobs using this parser' do
      expect(HarvestJob).to receive(:where).with(parser_id: parser_version.parser_id).and_return job
      parser_version.harvest_jobs
    end

    it 'finds all the harvest jobs with specified status' do
      expect(HarvestJob).to receive(:where).with(parser_id: parser_version.parser_id, status: 'finished') .and_return job
      parser_version.harvest_jobs('finished')
    end
  end

  describe '#source' do
    it 'finds parser through active resource and return its source' do
      allow(Parser).to receive(:find).and_return(parser)
      expect(parser_version.source).to eq parser.source
    end
  end
end
