#import <Foundation/Foundation.h>

@interface Decompresser: NSObject
@property NSInteger charIndex;
@property NSString *input;
- (NSInteger)decompressedLength;
@end

@implementation Decompresser

- (NSInteger)decompressedLength
{
	return [self _decompressedLengthWithStartIndex:0 segmentLength:self.input.length];
}

- (NSInteger)_decompressedLengthWithStartIndex:(NSInteger)startIndex segmentLength:(NSInteger)segmentLength
{
	NSInteger len = 0;
	self.charIndex = startIndex;
	while (self.charIndex < startIndex + segmentLength) {
		unichar ch = [self nextChar];
		if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:ch]) {
			// Skip whitespace characters.
		} else if (ch == '(') {
			NSInteger segmentLength = [self _parseIntWithEndChar:'x'];
			NSInteger repeatCount = [self _parseIntWithEndChar:')'];

			Decompresser *d = [[Decompresser alloc] init];
			d.input = self.input;
			len += repeatCount * [d _decompressedLengthWithStartIndex:self.charIndex segmentLength:segmentLength];

			self.charIndex += segmentLength;
		} else {
			len += 1;
		}
	}
	return len;
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
