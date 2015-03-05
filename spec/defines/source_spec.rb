require 'spec_helper'

describe 'apt::source' do
  GPG_KEY_ID = '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'

  let :pre_condition do
    'class { "apt": }'
  end

  let :title do
    'my_source'
  end

  context 'defaults' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end

    it { is_expected.to contain_apt__setting('list-my_source').with({
      :ensure  => 'present',
    }).without_content(/# my_source\ndeb-src  wheezy main\n/)
    }
  end

  describe 'no defaults' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end
    context 'with simple key' do
      let :params do
        {
          :comment           => 'foo',
          :location          => 'http://debian.mirror.iweb.ca/debian/',
          :release           => 'sid',
          :repos             => 'testing',
          :key               => GPG_KEY_ID,
          :pin               => '10',
          :architecture      => 'x86_64',
          :trusted_source    => true,
        }
      end

      it { is_expected.to contain_apt__setting('list-my_source').with({
        :ensure => 'present',
      }).with_content(/# foo\ndeb \[arch=x86_64 trusted=yes\] http:\/\/debian\.mirror\.iweb\.ca\/debian\/ sid testing\n/).without_content(/deb-src/)
      }

      it { is_expected.to contain_apt__pin('my_source').that_comes_before('Apt::Setting[list-my_source]').with({
        :ensure   => 'present',
        :priority => '10',
        :origin   => 'debian.mirror.iweb.ca',
      })
      }

      it { is_expected.to contain_apt__key("Add key: #{GPG_KEY_ID} from Apt::Source my_source").that_comes_before('Apt::Setting[list-my_source]').with({
        :ensure  => 'present',
        :id      => GPG_KEY_ID,
      })
      }
    end

    context 'with complex key' do
      let :params do
        {
          :comment           => 'foo',
          :location          => 'http://debian.mirror.iweb.ca/debian/',
          :release           => 'sid',
          :repos             => 'testing',
          :key               => { 'id' => GPG_KEY_ID, 'server' => 'pgp.mit.edu',
                                  'content' => 'GPG key content',
                                  'source'  => 'http://apt.puppetlabs.com/pubkey.gpg',},
          :pin               => '10',
          :architecture      => 'x86_64',
          :trusted_source    => true,
        }
      end

      it { is_expected.to contain_apt__setting('list-my_source').with({
        :ensure => 'present',
      }).with_content(/# foo\ndeb \[arch=x86_64 trusted=yes\] http:\/\/debian\.mirror\.iweb\.ca\/debian\/ sid testing\n/).without_content(/deb-src/)
      }

      it { is_expected.to contain_apt__pin('my_source').that_comes_before('Apt::Setting[list-my_source]').with({
        :ensure   => 'present',
        :priority => '10',
        :origin   => 'debian.mirror.iweb.ca',
      })
      }

      it { is_expected.to contain_apt__key("Add key: #{GPG_KEY_ID} from Apt::Source my_source").that_comes_before('Apt::Setting[list-my_source]').with({
        :ensure  => 'present',
        :id      => GPG_KEY_ID,
        :server  => 'pgp.mit.edu',
        :content => 'GPG key content',
        :source  => 'http://apt.puppetlabs.com/pubkey.gpg',
      })
      }
    end

    context 'with simple key' do
      let :params do
        {
          :comment        => 'foo',
          :location       => 'http://debian.mirror.iweb.ca/debian/',
          :release        => 'sid',
          :repos          => 'testing',
          :key            => GPG_KEY_ID,
          :pin            => '10',
          :architecture   => 'x86_64',
          :trusted_source => true,
        }
      end

      it { is_expected.to contain_apt__setting('list-my_source').with({
        :ensure => 'present',
      }).with_content(/# foo\ndeb \[arch=x86_64 trusted=yes\] http:\/\/debian\.mirror\.iweb\.ca\/debian\/ sid testing\n/).without_content(/deb-src/)
      }

      it { is_expected.to contain_apt__pin('my_source').that_comes_before('Apt::Setting[list-my_source]').with({
        :ensure   => 'present',
        :priority => '10',
        :origin   => 'debian.mirror.iweb.ca',
      })
      }

      it { is_expected.to contain_apt__key("Add key: #{GPG_KEY_ID} from Apt::Source my_source").that_comes_before('Apt::Setting[list-my_source]').with({
        :ensure  => 'present',
        :id      => GPG_KEY_ID,
      })
      }
    end
  end

  context 'trusted_source true' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end
    let :params do
      {
        :trusted_source => true,
      }
    end

    it { is_expected.to contain_apt__setting('list-my_source').with({
      :ensure => 'present',
    }).with_content(/# my_source\ndeb \[trusted=yes\]  wheezy main\n/)
    }
  end

  context 'architecture equals x86_64' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end
    let :params do
      {
        :include      => {'deb' => false, 'src' => true,},
        :architecture => 'x86_64',
      }
    end

    it { is_expected.to contain_apt__setting('list-my_source').with({
      :ensure => 'present',
    }).with_content(/# my_source\ndeb-src \[arch=x86_64 \]  wheezy main\n/)
    }
  end

  context 'ensure => absent' do
    let :facts do
      {
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'wheezy',
        :osfamily        => 'Debian'
      }
    end
    let :params do
      {
        :ensure => 'absent',
      }
    end

    it { is_expected.to contain_apt__setting('list-my_source').with({
      :ensure => 'absent'
    })
    }
  end

  describe 'validation' do
    context 'no release' do
      let :facts do
        {
          :lsbdistid       => 'Debian',
          :osfamily        => 'Debian'
        }
      end

      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /lsbdistcodename fact not available: release parameter required/)
      end
    end
  end
end
