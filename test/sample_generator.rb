require_relative '../lib/encoding_estimator'
require 'fileutils'

languages = {
    de: 'Temporäre Änderung der Straßenführung.',
    en: 'even in English, there are special characters, e.g. in brand names like Nestlé.',
    fr: 'Ruby est un langage de programmation libre. Il est interprété, orienté objet et multi-paradigme',
    unknown: 'Temporäre Änderung der Straßenführung.'
}

modes = {
    EncodingEstimator::Conversion::Operation::DECODE => EncodingEstimator::Conversion::Operation::ENCODE,
    EncodingEstimator::Conversion::Operation::ENCODE => EncodingEstimator::Conversion::Operation::DECODE
}

encodings = [
    'utf-8', 'iso-8859-1', 'utf-16le'
]

languages.each do |lang, content|
  modes.each do |opname,operation|
    encodings.each do |encoding|
      c = EncodingEstimator::Conversion.new( encoding, operation )
      s = c.perform content

      FileUtils.mkpath( './samples/' + opname.to_s + '/' + lang.to_s )
      File.open( './samples/' + opname.to_s + '/' + lang.to_s + '/' + encoding + '.txt', 'w' ) do |f|
        f.write s
      end
    end
  end
end