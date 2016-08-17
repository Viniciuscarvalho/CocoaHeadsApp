import UIKit

class EventsListViewModel: ViewModel {
    
    var numberOfItemsPerRequest = 20
    var currentPage = 0
    let items = Variable<[Event]>([])
    
    func loadMoreItens() {
        switch self.currentState.value {
        case .Loading:
            return
        case .Success:
            return
        case .noEvents:
            handleResponseNoEvents()
            return
        default:
            break
        }
        self.currentState.value = ViewModelState.InfiniteLoading
        MeetupAPIConsumer.consume(.ListEvents(perPage: self.numberOfItemsPerRequest,
            pageOffset:self.currentPage), success: self.handleAPIResponseSuccess, failure: self,
                                          handleAPIResponseFailure)
    }
    
    func handleAPIResponseSuccess(response :MeetupListResponse) {
        logger.debug("Loaded: \(response.results.count) meetups")
        self.items.appendContentOf(response.results)
        self.currentPage += 1
        dispatch_async(dispatch_get_main_queue()) {
            let newStatus :ViewModelState = response.meta.totalCount == self.items.value.count ? .Success : .Idle
            self.currentState.value = newStatus
        }
    }
    
    func handleAPIResponseFailure(error :ErrorType) {
        logger.error("Error: \(error)")
        self.currentState.value = .Error(error)
    }
    
    func handleResponseNoEvents() {
        var noEventLbl = UILabel(frame: CGRectMake(0,0,200,21))
        noEventLbl.center = CGPointMake(160, 284)
        noEventLbl.textAlignment = NSTextAlignment.Center
        noEventLbl.textColor = UIColor.grayColor()
        noEventLbl.text = "Nenhum evento ainda"
        
        var sadCocoaImg = UIImage(named: "cocoaheads-sad")
        sadCocoaImg = UIImageView(frame:CGRectMake(0, 0, 100, 70))
        sadCocoaImg.contentMode = .ScaleAspectFit
        
    }
}
