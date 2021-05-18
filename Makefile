.PHONY: put poll

put:
	rsync -vrt --delete --exclude=.git \
	--exclude=data \
	--exclude=doc \
	--exclude=test \
	--exclude=trig \
	--exclude=published \
	--exclude=tool \
	. /Volumes/Elder\ Scrolls\ Online/live/AddOns/ZZCrowAndCountess


poll: put

