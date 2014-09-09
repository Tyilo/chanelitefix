static NSDictionary *replacementRules;

%hook TTURLRequest

- (id)initWithURL:(NSString *)url delegate:(id)delegate {
	NSMutableString *new = [url mutableCopy];
	
	for(NSString *pattern in replacementRules) {
		id replacement = replacementRules[pattern];
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
		if([replacement isKindOfClass:[NSString class]]) {
			[regex replaceMatchesInString:new options:0 range:NSMakeRange(0, [new length]) withTemplate:replacement];
		} else if([replacement isKindOfClass:%c(NSBlock)]) {
			NSTextCheckingResult *result = [regex firstMatchInString:new options:0 range:NSMakeRange(0, [new length])];
			if(result && [result range].location != NSNotFound) {
				for(int i = 0; i < [result numberOfRanges]; i++) {
					NSRange range = [result rangeAtIndex:i];
					NSString *match = [new substringWithRange:range];
					NSString *rep = ((NSString *(^)(int, NSString *))replacement)(i, match);
					if(rep) {
						[new replaceCharactersInRange:range withString:rep];
					}
				}
			}
		}
	}
	
	//NSLog(@"%@ -> %@", url, new);

	return %orig(new, delegate);
}

%end

%ctor {
	replacementRules = @{
		@"^(https?)://thumbs.4cdn.org/([^/]+)/thumb/(.+)":
			@"$1://t.4cdn.org/$2/$3",
		@"^(https?)://images.4cdn.org/([^/]+)/src/(.+)":
			@"$1://i.4cdn.org/$2/$3",
		@"^https?://api.4chan.org/[^/]+/([0-9]+).json$": ^(int group, NSString *match) {
			if(group == 1) {
				return [NSString stringWithFormat:@"%d", [match intValue] + 1];
			} else {
				return (NSString *)nil;
			}
		}
	};
}
