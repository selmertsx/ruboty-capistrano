require 'spec_helper'
require 'ruboty/capistrano/verification'
require 'ruboty/capistrano/deploy_source'

describe Ruboty::Capistrano::Verification do
  let(:deploy_source) { Ruboty::Capistrano::DeploySource.new(repo, branch) }
  let(:verification) do
    Ruboty::Capistrano::Verification.new(
      env: env,
      role: role,
      deploy_source: deploy_source
    )
  end
  let(:env) { 'staging' }
  let(:role) { 'admin' }
  let(:repo) { 'sample_repo' }
  let(:branch) { 'master' }

  describe '#prod_branch_limit' do
    context '正常系' do
      it { expect(verification.prod_branch_limit).to be_nil }
    end

    context 'production環境にmaster以外をデプロイしようとした時' do
      let(:env) { 'production' }
      let(:branch) { 'test' }

      it { expect { verification.prod_branch_limit }.to raise_error(Ruboty::Capistrano::Verification::InvalidDeploySettingError) }
    end
  end

  describe '#exist_branch_check' do
    context 'github上の指定したリポジトリにブランチが存在する時' do
      before do
        allow(deploy_source).to receive(:exist_github?).and_return(true)
      end

      it { expect(verification.exist_branch_check).to be_nil }
    end

    context 'ブランチが存在しない時' do
      before do
        allow(deploy_source).to receive(:exist_github?).and_return(false)
      end

      it { expect { verification.exist_branch_check }.to raise_error(Ruboty::Capistrano::Verification::NoBranchError) }
    end
  end
end