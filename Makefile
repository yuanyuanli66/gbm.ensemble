prepareTNBCbulkRNAandSingleCell:
	cd s0101; bash ss01a.sh;

findXgbParamTNBCbulkRNAandSingleCell:
	cd s0102; bash ss01a.sh;
findXgbParamRefindedTNBCbulkRNAandSingleCell:
	cd s0102; bash ss02a.sh;

predictViaRepeatedCvXgbTNBCbulkRNAandSingleCell:
	cd s0103; bash ss01a.sh;


realclean:
	@find ./ -name "*~" -exec rm -rf {} \;
















