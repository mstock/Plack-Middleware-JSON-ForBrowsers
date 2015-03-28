requires "Carp" => "0";
requires "Encode" => "0";
requires "HTML::Entities" => "0";
requires "JSON" => "0";
requires "List::MoreUtils" => "0";
requires "MRO::Compat" => "0";
requires "Plack::Middleware" => "0";
requires "Plack::Util::Accessor" => "0";
requires "parent" => "0";
requires "strict" => "0";
requires "warnings" => "0";

on 'build' => sub {
  requires "Module::Build" => "0.3601";
};

on 'test' => sub {
  requires "File::Find" => "0";
  requires "File::Temp" => "0";
  requires "HTTP::Request::Common" => "0";
  requires "Plack::Test" => "0";
  requires "Plack::Util" => "0";
  requires "Test::Class" => "0";
  requires "Test::More" => "0.88";
};

on 'configure' => sub {
  requires "Module::Build" => "0.3601";
};

on 'develop' => sub {
  requires "Test::CPAN::Changes" => "0.19";
  requires "version" => "0.9901";
};
