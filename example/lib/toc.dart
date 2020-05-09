import 'dart:convert';
import 'package:flutter/material.dart';
import 'samples.dart';

typedef void SampleFunc(Function(Object) print);
typedef Future SampleFuncAsync(Function(Object) print);

class Section extends Topic {
  Section(String title) : super(title);
}

class Topic {
  final String title;
  final String description;
  final String url;
  final List<Sample> samples;

  Topic(this.title, {this.description, this.url, this.samples});
}

class Sample {
  final String name;
  final SampleFunc func;
  final SampleFuncAsync funcAsync;
  String title;
  String description;
  String code;

  Sample(this.name, {this.func, this.funcAsync});
}

Future<List<Topic>> buildToc(BuildContext context) async {
  final toc = [
    Section('Common'),
    Topic('APIs',
        description:
            'The flutter_sodium library contains two sets of APIs, a core API and a high-level API. The core API maps native libsodium function 1:1 to Dart equivalents. The high-level API provides Dart-friendly, opinionated access to libsodium.',
        samples: <Sample>[
          Sample('api1', func: api1),
          Sample('api2', func: api2)
        ]),
    Topic('Random data',
        description:
            'Provides a set of functions to generate unpredictable data, suitable for creating secret keys.',
        url: 'https://libsodium.gitbook.io/doc/generating_random_data/',
        samples: <Sample>[
          Sample('random1', func: random1),
          Sample('random2', func: random2),
          Sample('random3', func: random3)
        ]),
    Topic('Version',
        description: 'Provides libsodium version info.',
        url: 'https://libsodium.gitbook.io/doc/',
        samples: <Sample>[Sample('version1', func: version1)]),
    Section('Secret-key cryptography'),
    Topic('Authenticated encryption',
        description: 'Secret-key encryption and verification',
        url:
            'https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox',
        samples: <Sample>[]),
    Topic('Authentication',
        description:
            'Computes an authentication tag for a message and a secret key, and provides a way to verify that a given tag is valid for a given message and a key.',
        url:
            'https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication',
        samples: <Sample>[]),
    Topic('Original ChaCha20-Poly1305',
        description: 'Authenticated Encryption with Additional Data.',
        url:
            'https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction',
        samples: <Sample>[]),
    Topic('IETF ChaCha20-Poly1305',
        description: 'Authenticated Encryption with Additional Data',
        url:
            'https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/ietf_chacha20-poly1305_construction',
        samples: <Sample>[]),
    Topic('XChaCha20-Poly1305',
        description: 'Authenticated Encryption with Additional Data.',
        url:
            'https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction',
        samples: <Sample>[]),
    Section('Public-key cryptography'),
    Topic('Authenticated encryption',
        description: 'Public-key authenticated encryption',
        url:
            'https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption',
        samples: <Sample>[]),
    Topic('Public-key signatures',
        description:
            'Computes a signature for a message using a secret key, and provides verification using a public key.',
        url:
            'https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures',
        samples: <Sample>[]),
    Topic('Sealed boxes',
        description:
            'Anonymously send encrypted messages to a recipient given its public key.',
        url:
            'https://libsodium.gitbook.io/doc/public-key_cryptography/sealed_boxes',
        samples: <Sample>[]),
    Section('Hashing'),
    Topic('Generic hashing',
        description:
            'Computes a fixed-length fingerprint for an arbitrary long message using the BLAKE2b algorithm.',
        url: 'https://libsodium.gitbook.io/doc/hashing/generic_hashing',
        samples: <Sample>[
          Sample('generic1', func: generic1),
          Sample('generic2', func: generic2)
        ]),
    Topic('Short-input hashing',
        description: 'Computes short hashes using the SipHash-2-4 algorithm.',
        url: 'https://libsodium.gitbook.io/doc/hashing/short-input_hashing',
        samples: <Sample>[]),
    Topic('Password hashing',
        description:
            'Provides an Argon2 password hashing scheme implementation.',
        url:
            'https://libsodium.gitbook.io/doc/password_hashing/the_argon2i_function',
        samples: <Sample>[
          Sample('pwhash1', func: pwhash1),
          Sample('pwhash2', func: pwhash2),
          Sample('pwhash3', funcAsync: pwhash3),
        ]),
    Section('Key functions'),
    Topic('Key derivation',
        description: 'Derive secret subkeys from a single master key.',
        url: 'https://libsodium.gitbook.io/doc/key_derivation/',
        samples: <Sample>[]),
    Topic('Key exchange',
        description: 'Securely compute a set of shared keys.',
        url: 'https://libsodium.gitbook.io/doc/key_exchange/',
        samples: <Sample>[]),
    Section('Advanced'),
    Topic('Diffie-Hellman',
        description: 'Perform scalar multiplication of elliptic curve points',
        url: 'https://libsodium.gitbook.io/doc/advanced/scalar_multiplication',
        samples: <Sample>[]),
    Topic('One-time authentication',
        description: 'Secret-key single-message authentication using Poly1305',
        url: 'https://libsodium.gitbook.io/doc/advanced/poly1305',
        samples: <Sample>[]),
    Topic('Ed25519 To Curve25519 Secret Key',
        description:
            'Converts an Ed25519 Secret Key to a Curve25519 Secret Key',
        url: 'https://download.libsodium.org/doc/advanced/ed25519-curve25519',
        samples: <Sample>[])
  ];

  // load asset samples.dart for code snippets
  final src =
      await DefaultAssetBundle.of(context).loadString('lib/samples.dart');

  // iterate all samples in the toc, and parse title, description and code snippet
  for (var topic in toc) {
    if (topic.samples != null) {
      for (var sample in topic.samples) {
        final beginTag = '// BEGIN ${sample.name}:';
        final begin = src.indexOf(beginTag);
        assert(begin != -1);

        // parse title
        final beginTitle = begin + beginTag.length;
        final endTitle = src.indexOf(':', beginTitle);
        assert(endTitle != -1);
        sample.title = src.substring(beginTitle, endTitle).trim();

        // parse description
        final endDescription = src.indexOf('\n', endTitle);
        assert(endDescription != -1);
        sample.description = src.substring(endTitle + 1, endDescription).trim();

        final end = src.indexOf('// END ${sample.name}', endDescription);
        assert(end != -1);

        sample.code = _formatCode(src.substring(endDescription, end));
      }
    }
  }

  return toc;
}

String _formatCode(String code) {
  final result = StringBuffer();
  final lines = LineSplitter.split(code).toList();
  int indent = -1;
  for (var i = 0; i < lines.length; i++) {
    String line = lines[i];
    // skip empty first and last lines
    if (line.trim().length == 0 && (i == 0 || i == lines.length - 1)) {
      continue;
    }
    // determine indent
    if (indent == -1) {
      for (indent = 0; indent < line.length; indent++) {
        if (line[indent] != ' ') {
          break;
        }
      }
    }

    // remove indent from line
    if (line.startsWith(' ' * indent)) {
      line = line.substring(indent);
    }

    if (result.isNotEmpty) {
      result.writeln();
    }
    result.write(line);
  }
  return result.toString();
}