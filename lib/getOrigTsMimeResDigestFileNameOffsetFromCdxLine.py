@outputSchema("text:chararray")
def getOrigTsMimeResDigestFileNameOffsetFromCdxLine(cdxLine):
   if not cdxLine:
      return None
   cdxParts = cdxLine.split(" ")
   if len(cdxParts) < 9:
      return None
   return cdxParts[2] + "\t" + cdxParts[1] + "\t" + cdxParts[3] + "\t" + cdxParts[4] + "\t" + cdxParts[5] + "\t" + cdxParts[-1] + "\t" + cdxParts[-2]
