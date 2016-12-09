#import <Foundation/Foundation.h>

@interface Decompresser: NSObject
@property NSInteger charIndex;
@property NSString *input;
- (NSInteger)decompressedLength;
@end

@implementation Decompresser

- (NSInteger)decompressedLength
{
	NSInteger outputLength = 0;
	self.charIndex = 0;
	while (self.charIndex < self.input.length) {
		unichar ch = [self nextChar];
		if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:ch]) {
			// Skip whitespace characters.
		} else if (ch == '(') {
			NSInteger segmentLength = [self _parseIntWithEndChar:'x'];
			NSInteger repeatCount = [self _parseIntWithEndChar:')'];
			self.charIndex += segmentLength;
			outputLength += segmentLength * repeatCount;
		} else {
			outputLength += 1;
		}
	}
	return outputLength;
}
	
- (NSInteger)_parseIntWithEndChar:(unichar)endChar
{
	NSMutableString *s = [NSMutableString string];
	while (YES) {
		unichar ch = [self nextChar];
		if (ch == endChar) {
			return s.integerValue;
		} else {
			[s appendFormat:@"%c", ch];
		}
	}
}
	
- (unichar)nextChar
{
	unichar ch = [self.input characterAtIndex:self.charIndex];
	self.charIndex += 1;
	return ch;
}

@end


int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSString *arg0 = [[NSProcessInfo processInfo] arguments][0];
		NSURL *dirURL = [[NSURL fileURLWithPath:arg0] URLByDeletingLastPathComponent];
		NSURL *fileURL = [dirURL URLByAppendingPathComponent:@"input.txt"];  // "input.txt" or "test.txt"
		NSString *fileContents = [NSString stringWithContentsOfURL:fileURL];
		
		Decompresser *d = [[Decompresser alloc] init];
		d.input = fileContents;
		NSLog(@"decompressedLength: %ld", [d decompressedLength]);
	}
}
