import argparse
import urllib
import urllib2
import os
import sys

parser = argparse.ArgumentParser()
parser.add_argument("-action", choices=["ADD", "DELETE"],required=True)
#group = parser.add_mutually_exclusive_group()
groupInputfile = parser.add_argument_group("from input file", "Parameters from input file")
groupInputfile = parser.add_argument_group()
groupInputfile.add_argument("-i", help="Input deployment json file")
#groupInputfile.add_argument("-action", choices=["ADD", "DELETE"])

groupParameters = parser.add_argument_group("from parameters", "Parameters provided")
#groupParameters = parser.add_argument_group()
groupParameters.add_argument("-branch", help="Branch name(ex:master)",required=True)
groupParameters.add_argument("-version", help="Artifact version (ex:1.2.3,latest",required=True)
groupParameters.add_argument("-name", help="Artifact name (ex:prodution, integration",required=True)
groupParameters.add_argument("-file", help="Artifact file (.IPA,.APK",required=True)


args = parser.parse_args()
print args
#artifacts/{apiKey}/{branch}/{version}/{artifactName}')