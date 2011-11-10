//
//  ShootStatusInputTableViewCell.m
//  ShootStudio
//
//  Created by Tom Fewster on 18/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ShootStatusInputTableViewCell.h"
#import "Shoot+Utils.h"

@implementation ShootStatusInputTableViewCell

@synthesize status;
@synthesize statusPicker;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.statusPicker = [[[UIPickerView alloc] initWithFrame:CGRectZero] autorelease];
		self.statusPicker.showsSelectionIndicator = YES;
		self.statusPicker.delegate = self;
		self.statusPicker.dataSource = self;
		self.statusPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[self.statusPicker selectRow:self.status inComponent:0 animated:YES];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		self.statusPicker = [[[UIPickerView alloc] initWithFrame:CGRectZero] autorelease];
		self.statusPicker.showsSelectionIndicator = YES;
		self.statusPicker.delegate = self;
		self.statusPicker.dataSource = self;
		self.statusPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[self.statusPicker selectRow:self.status inComponent:0 animated:YES];
    }
    return self;
}

- (void)dealloc {
	self.statusPicker = nil;
	[super dealloc];
}

- (UIView *)inputView {
	return self.statusPicker;
}

- (void)setStatus:(kShootStatusValues)value {
	status = value;
	self.detailTextLabel.text = [Shoot shootStatusAsString:self.status];
}

- (BOOL)becomeFirstResponder {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	return [super resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	if (selected) {
		[self becomeFirstResponder];
	}
}

- (void)keyboardWillShow:(NSNotification*)notification {
	NSDictionary *userInfo = [notification userInfo];    
    // Get the origin of the keyboard when it's displayed.

	CGRect keyboardRect = CGRectZero;
	keyboardRect.size = [self.statusPicker sizeThatFits:CGSizeZero];
	keyboardRect.origin = CGPointZero;
	
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
	 
	[UIView animateWithDuration:animationDuration animations:^{
		self.statusPicker.frame = keyboardRect;
	} completion:^(BOOL finished) {
		[self.statusPicker setNeedsLayout];
	}];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {

	UITableView *tableView = (UITableView *)self.superview;
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
/*	
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
	
    CGRect aRect = tableView.frame;
    aRect.size.height -= kbSize.height + self.frame.size.height + 20.0f;
    if (!CGRectContainsPoint(aRect, self.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.frame.origin.y - kbSize.height + self.frame.size.height + 20.0f);
        [tableView setContentOffset:scrollPoint animated:YES];
    }
*/	
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
	UITableView *tableView = (UITableView *)self.superview;
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
}


#pragma mark -
#pragma mark Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder {
	return YES;
}

#pragma mark -
#pragma mark UIKeyInput Protocol Methods

- (BOOL)hasText {
	return YES;
}

- (void)insertText:(NSString *)theText {
}

- (void)deleteBackward {
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [[Shoot shootStatus] count];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [[Shoot shootStatus] objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 44.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return pickerView.bounds.size.width - 20.0f;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.status = row;
	if (delegate && [delegate respondsToSelector:@selector(tableViewCell:didEndEditingWithStatus:)]) {
		[delegate tableViewCell:self didEndEditingWithStatus:self.status];
	}
}

@end