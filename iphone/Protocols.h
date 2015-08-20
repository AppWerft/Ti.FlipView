//
//  Protocols.h
//  IosFlipview
//
//  Created by Stefan Gross on 18.10.14.
//
//

#ifndef IosFlipview_Protocols_h
#define IosFlipview_Protocols_h

@protocol BCBPageFlipperDataSource

- (NSInteger)numberOfPages;
- (UIView*)viewForPage:(NSInteger)page withBounds:(CGRect)bounds;

@end


@protocol BCBPageFlipperDelegate
@optional
- (void)pageChanged:(NSInteger)currentPage withPageCount:(NSInteger)pageCount;
- (void)pageTapped:(NSInteger)currentPage;
- (void)transitionStarted;
@end


#endif
