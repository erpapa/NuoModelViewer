//
//  ModelPartsList.m
//  ModelViewer
//
//  Created by middleware on 1/7/17.
//  Copyright © 2017 middleware. All rights reserved.
//

#import "ModelPartsPanel.h"
#import "NuoMesh.h"
#import "ModelOptionUpdate.h"
#import "ModelPanelUpdate.h"





@interface ModelBoolView : NSButton

@end


@interface ModelTextView : NSTextField <NSTextFieldDelegate>

@end


@interface ModelNumberValueFormatter : NSNumberFormatter

@end



@interface ModelPartsListTable : NSTableView < NSTableViewDataSource, NSTableViewDelegate >


@property (nonatomic, weak) id<ModelOptionUpdate> updateDelegate;
@property (nonatomic, weak) id<ModelPanelUpdate> panelUpdateDelegate;
@property (nonatomic, weak) NSArray<NuoMesh*>* mesh;

@property (nonatomic, assign, setter=setRowsBeingUpdated:) BOOL rowsBeingUpdated;

- (void)cellEnablingChanged:(id)sender;
- (void)smoothToleranceChanged:(id)sender;

- (void)updateWithReload:(BOOL)reload;


@end



@implementation ModelBoolView

- (void)setObjectValue:(id)value
{
    bool enabled = [value integerValue] != 0;
    [self setState:enabled ? NSControlStateValueOn : NSControlStateValueOff];
}


- (id)objectValue
{
    return @(self.state == NSControlStateValueOn);
}

- (void)mouseDown:(NSEvent *)event
{
    [super mouseDown:event];
    
    ModelPartsListTable* table = (ModelPartsListTable*)self.target;
    [table cellEnablingChanged:self];
}

@end



@implementation ModelTextView


- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    ModelPartsListTable* table = (ModelPartsListTable*)self.target;
    [table setRowsBeingUpdated:YES];
    [table smoothToleranceChanged:self];
    [table setRowsBeingUpdated:NO];
    
    return YES;
}


@end



@implementation ModelNumberValueFormatter

- (BOOL)isPartialStringValid:(NSString*)partialString
            newEditingString:(NSString**)newString
            errorDescription:(NSString**)error
{
    if ([partialString length] == 0)
        return YES;
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanFloat:nil] && [scanner isAtEnd]))
    {
        NSBeep();
        return NO;
    }
    
    return YES;
}

@end



@implementation ModelPartsListTable



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setAllowsMultipleSelection:YES];
        [self setDataSource:self];
        [self setDelegate:self];
    }
    return self;
}


- (void)updateWithReload:(BOOL)reload
{
    // when the change is fired by the row itself, ignore the reload
    //
    if ([self rowsBeingUpdated])
        return;
    
    if (reload)
    {
        [self reloadData];
    }
    else
    {
        NSIndexSet* rowSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfRows)];
        NSIndexSet* colSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfColumns)];
        [self reloadDataForRowIndexes:rowSet columnIndexes:colSet];
    }
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _mesh.count;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    NSView* result = [self makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if ([tableColumn.identifier isEqualToString:@"enabled"])
    {
        ModelBoolView* boolView = (ModelBoolView*)result;
        boolView.objectValue = @(_mesh[row].enabled);
        boolView.target = self;
    }
    else if ([tableColumn.identifier isEqualToString:@"name"])
    {
        NSTableCellView* cell = (NSTableCellView*)result;
        NSTextField* textField = cell.textField;
        textField.stringValue = _mesh[row].modelName;
    }
    else
    {
        NSTableCellView* cell = (NSTableCellView*)result;
        ModelTextView* textField = (ModelTextView*)cell.textField;
        
        ModelNumberValueFormatter* numberFormatter = [[ModelNumberValueFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.minimumFractionDigits = 4;
        
        textField.formatter = numberFormatter;
        textField.delegate = textField;
        textField.target = self;
        textField.stringValue = [NSString stringWithFormat:@"%0.4f", _mesh[row].smoothTolerance];
    }
    
    return result;
}


- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    NSMutableArray<NuoMesh*>* result = [[NSMutableArray alloc] init];
    
    NSUInteger selected = [proposedSelectionIndexes firstIndex];
    while (selected != NSNotFound)
    {
        [result addObject:_mesh[selected]];
        selected = [proposedSelectionIndexes indexGreaterThanIndex:selected];
    }
    
    [_panelUpdateDelegate modelPartSelectionChanged:result];
    [_updateDelegate modelPartsSelectionChanged:result];
    
    return proposedSelectionIndexes;
}


- (void)cellEnablingChanged:(id)sender
{
    NSInteger row = [self rowForView:sender];
    ModelBoolView* enableButton = (ModelBoolView*)sender;
    _mesh[row].enabled = enableButton.state == NSControlStateValueOn;
    
    [_updateDelegate modelOptionUpdate:0];
}


- (void)smoothToleranceChanged:(id)sender
{
    NSInteger row = [self rowForView:sender];
    NSTextField* textField = (NSTextField*)sender;
    NSString* valueStr = textField.stringValue;
    
    float value;
    NSScanner* scanner = [[NSScanner alloc] initWithString:valueStr];
    [scanner scanFloat:&value];
    
    if ([scanner isAtEnd])
    {
        [_mesh[row] smoothWithTolerance:value];
        [_updateDelegate modelOptionUpdate:0];
    }
}


@end






@implementation ModelPartsPanel
{
    IBOutlet ModelPartsListTable* _partsTable;
    IBOutlet NSScrollView* _partsList;
}


- (CALayer*)makeBackingLayer
{
    return [CALayer new];
}


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"ModelPartsTableView"
                                      owner:self topLevelObjects:nil];

        [self setWantsLayer:YES];
        [self addSubview:_partsList];
    }
    
    return self;
}



- (void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    [_partsList setFrame:self.bounds];
}



- (void)viewDidEndLiveResize
{
    [_partsList setFrame:self.bounds];
}



- (void)setMesh:(NSArray<NuoMesh*>*)mesh
{
    [_partsTable setMesh:mesh];
    [_partsTable reloadData];
}


- (void)updateParsPanelWithReload:(BOOL)reload
{
    [_partsTable updateWithReload:reload];
}


- (void)setOptionUpdateDelegate:(id<ModelOptionUpdate>)optionUpdateDelegate
{
    _partsTable.updateDelegate = optionUpdateDelegate;
}


- (void)setPanelUpdateDelegate:(id<ModelPanelUpdate>)panelUpdateDelegate
{
    _partsTable.panelUpdateDelegate = panelUpdateDelegate;
}




@end
